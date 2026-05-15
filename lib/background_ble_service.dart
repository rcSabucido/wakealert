import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const _notificationChannelId = 'ble_foreground_channel';
const _notificationId = 1001;

// ---------------------------------------------------------------------------
// Service initializer — call this from main() before runApp()
// ---------------------------------------------------------------------------

Future<void> initBackgroundBleService() async {
  final service = FlutterBackgroundService();

  const channel = AndroidNotificationChannel(
    _notificationChannelId,
    'BLE Background Service',
    description: 'Keeps the BLE connection alive in the background.',
    importance: Importance.low,
  );

  final notifications = FlutterLocalNotificationsPlugin();

  debugPrint('Service Created');

  await notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onServiceStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: _notificationChannelId,
      initialNotificationTitle: 'BLE Service',
      initialNotificationContent: 'Starting…',
      foregroundServiceNotificationId: _notificationId,
      // Required for Android 14+ (SDK 34)
      foregroundServiceTypes: [AndroidForegroundType.connectedDevice],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onServiceStart,
      onBackground: onIosBackground,
    ),
  );
}

// ---------------------------------------------------------------------------
// iOS background handler (limited — ~15–30 s every 15 min)
// ---------------------------------------------------------------------------

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  await dotenv.load(fileName: '.env');
  
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

// ---------------------------------------------------------------------------
// Main background service entry point
// ---------------------------------------------------------------------------

@pragma('vm:entry-point')
void onServiceStart(ServiceInstance service) async {
  // Required for Flutter 3+
  DartPluginRegistrant.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final notifications = FlutterLocalNotificationsPlugin();

  // Handle stop command from UI
  service.on('stopService').listen((_) => service.stopSelf());

  // Kick off the BLE logic
  await _runBleConnection(service, notifications);
}

// ---------------------------------------------------------------------------
// BLE connection + notification loop
// ---------------------------------------------------------------------------

Future<void> _runBleConnection(
  ServiceInstance service,
  FlutterLocalNotificationsPlugin notifications,
) async {
  _updateNotification(notifications, 'Scanning for device…');

  BluetoothDevice? targetDevice;

  String bleMac = dotenv.get('BLE_MAC');

  debugPrint("[BLE] Scanning for device: $bleMac");

  // ── 1. Scan for the target device ────────────────────────────────────────
  final scanSub = FlutterBluePlus.onScanResults.listen((results) {
    int len = results.length;
    debugPrint("Scan results: $len");
    for (final r in results) {
      String mac = r.device.remoteId.str;
      String name = r.device.name;
      debugPrint("[BLE] Found: $name ($mac)");
      if (r.device.remoteId.str == bleMac) {
        targetDevice = r.device;
        FlutterBluePlus.stopScan();
        break;
      }
    }
  });

  await FlutterBluePlus.startScan(
    withRemoteIds: [bleMac],
    timeout: const Duration(seconds: 15),
  );
  await FlutterBluePlus.isScanning.where((v) => !v).first;
  scanSub.cancel();

  if (targetDevice == null) {
    _updateNotification(notifications, 'Device not found. Retrying in 30 s…');
    // Retry after a delay
    await Future.delayed(const Duration(seconds: 30));
    return _runBleConnection(service, notifications);
  }

  final device = targetDevice!;

  // ── 2. Listen for disconnection → reconnect ───────────────────────────────
  final connSub = device.connectionState.listen((state) async {
    if (state == BluetoothConnectionState.disconnected) {
      debugPrint('[BLE] Disconnected: ${device.disconnectReason?.description}');
      _updateNotification(notifications, 'Disconnected. Reconnecting…');
      // Re-run the whole flow
      await Future.delayed(const Duration(seconds: 3));
      _runBleConnection(service, notifications);
    }
  });

  device.cancelWhenDisconnected(connSub, delayed: true, next: true);

  // ── 3. Connect ────────────────────────────────────────────────────────────
  try {
    _updateNotification(notifications, 'Connecting…');
    await device.connect(license: License.free, timeout: const Duration(seconds: 15));
  } catch (e) {
    debugPrint('[BLE] Connect error: $e');
    _updateNotification(notifications, 'Connection failed. Retrying…');
    await Future.delayed(const Duration(seconds: 5));
    return _runBleConnection(service, notifications);
  }

  _updateNotification(notifications, 'Connected to ${device.platformName}');

  // ── 4. Discover services ──────────────────────────────────────────────────
  final services = await device.discoverServices();

  BluetoothCharacteristic? targetChar;
  for (final s in services) {
    if (s.uuid == Guid(dotenv.get('BLE_SERVICE_UUID'))) {
      for (final c in s.characteristics) {
        if (c.uuid == Guid(dotenv.get('BLE_CHAR_READ_UUID'))) {
          targetChar = c;
          break;
        }
      }
    }
  }

  if (targetChar == null) {
    debugPrint('[BLE] Characteristic not found');
    _updateNotification(notifications, 'Characteristic not found');
    await device.disconnect();
    return;
  }

  // ── 5. Subscribe to notifications ─────────────────────────────────────────
  final charSub = targetChar.onValueReceived.listen((bytes) {
    _onDataReceived(bytes, service, notifications);
  });

  device.cancelWhenDisconnected(charSub);

  await targetChar.setNotifyValue(true);

  // After targetChar is found, register a write listener
  service.on('bleWrite').listen((data) async {
    if (data == null) return;
    final List<int> bytes = List<int>.from(data['bytes']);
    try {
      await targetChar!.write(bytes, withoutResponse: false);
      debugPrint('[BLE] Wrote bytes: $bytes');
    } catch (e) {
      debugPrint('[BLE] Write error: $e');
    }
  });

  _updateNotification(notifications, 'Receiving data from ${device.platformName}');
}

// ---------------------------------------------------------------------------
// Called every time a byte-array notification arrives
// ---------------------------------------------------------------------------

void _onDataReceived(
  List<int> bytes,
  ServiceInstance service,
  FlutterLocalNotificationsPlugin notifications,
) {
  debugPrint('[BLE] Received ${bytes.length} bytes: $bytes');

  // Forward the raw bytes to the UI isolate as a hex string list
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();
  service.invoke('bleData', {'bytes': hex});

  _updateNotification(
    notifications,
    'Last packet: ${hex.join(' ')}',
  );
}

// ---------------------------------------------------------------------------
// Helper: update the persistent foreground notification
// ---------------------------------------------------------------------------

void _updateNotification(
  FlutterLocalNotificationsPlugin notifications,
  String content,
) {
  notifications.show(
    id: _notificationId,
    title: 'BLE Service',
    body: content,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        _notificationChannelId,
        'BLE Background Service',
        icon: 'ic_bg_service_small',
        ongoing: true,
        importance: Importance.low,
        priority: Priority.low,
      ),
    ),
  );
}
