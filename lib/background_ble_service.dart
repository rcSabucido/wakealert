import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

import 'package:pro_mpack/pro_mpack.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:typed_data';

import 'package:wakealert/components/screenLoader.dart';
import 'package:wakealert/prefs_names.dart' as PrefsNames;
import 'package:wakealert/services/alert_service.dart';

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
    _updateNotification(notifications, 'Device not found. Retrying in 3 s…');
    // Retry after a delay
    await Future.delayed(const Duration(seconds: 3));
    return _runBleConnection(service, notifications);
  }

  final device = targetDevice!;

  // ── 2. Listen for disconnection → reconnect ───────────────────────────────
  final connSub = device.connectionState.listen((state) async {
    if (state == BluetoothConnectionState.disconnected) {
      debugPrint('[BLE] Disconnected: ${device.disconnectReason?.description}');
      service.invoke('bleState', {'state': 'disconnected'});
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
    service.invoke('bleState', {'state': 'connected', 'name': device.platformName});
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
  BluetoothCharacteristic? writeChar;
  for (final s in services) {
    if (s.uuid == Guid(dotenv.get('BLE_SERVICE_UUID'))) {
      for (final c in s.characteristics) {
        if (c.uuid == Guid(dotenv.get('BLE_CHAR_READ_UUID'))) {
          targetChar = c;
        }
        if (c.uuid == Guid(dotenv.get('BLE_CHAR_WRITE_UUID'))) {
          writeChar = c;
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

  final prefs = await SharedPreferences.getInstance();

  final checkInterval = prefs.getInt(PrefsNames.WELLNESS_CHECK_INTERVAL) ?? 60;
  final checkEnabled = prefs.getBool(PrefsNames.WELLNESS_CHECK_ENABLED) ?? false;

  final Uint8List startBytes = serialize([
    10,
    checkEnabled,
    checkInterval
  ]);

  await writeChar!.write(startBytes, withoutResponse: false);

  await targetChar.setNotifyValue(true);

  service.on('bleWrite').listen((data) async {
    if (data == null) return;
    final List<int> bytes = List<int>.from(data['bytes']);
    try {
      await writeChar!.write(bytes, withoutResponse: false);
      debugPrint('[BLE] Wrote bytes: $bytes');
    } catch (e) {
      debugPrint('[BLE] Write error: $e');
    }
  });

  service.on('blobTransfer').listen((data) async {
    if (data == null) return;
    final String name = data['name'] as String;
    final List<int> raw = List<int>.from(data['bytes']);
    try {
      await sendBlobTransfer(device, writeChar!, name, Uint8List.fromList(raw));
    } catch (e) {
      debugPrint('[BLE] Blob transfer error: $e');
    }
  });

  service.on('blobTransferBatch').listen((data) async {
    if (data == null) return;
    final list = List<Map<String, dynamic>>.from(data['data']);
    try {
      for(var i = 0; i < list.length; i++) {
        final List<int> raw = List<int>.from(list[i]["bytes"]);
        await sendBlobTransfer(device, writeChar!, list[i]["name"], Uint8List.fromList(raw));
      }
      service.invoke('batchTransferFinished', {});
    } catch (e) {
      debugPrint('[BLE] Blob transfer error: $e');
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
  final String distressData = "Distress signal";

  if (utf8.decode(bytes) == distressData) {
    debugPrint("Distress signal received.");

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getCurrentPosition(locationSettings: locationSettings).then((position) async {
      final prefs = await SharedPreferences.getInstance();
      AlertService.smsAlert(
        victimId: prefs.getInt(PrefsNames.VICTIM_ID)!,
        latitude: position.latitude,   
        longitude: position.longitude,
        service: service,
      );
      AlertService.addAlert(
        victimId: prefs.getInt(PrefsNames.VICTIM_ID)!,
        latitude: position.latitude,   
        longitude: position.longitude,   
      );
    });
  }

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

Uint8List intToBytes(int value) {
  final bytes = ByteData(4); // 4 bytes for a 32-bit integer
  bytes.setInt32(0, value, Endian.little); // or Endian.big

  return bytes.buffer.asUint8List();
}

// ---------------------------------------------------------------------------
// Chunked blob transfer over BLE (MessagePack framed)
//
// Start frame → [uint32:2, uint32:totalLen, str:name, uint32:numChunks]
// Chunk frame → [uint32:3, uint32:chunkIndex, uint32:chunkLen, bin:chunk]
// ---------------------------------------------------------------------------

Future<void> sendBlobTransfer(
  BluetoothDevice device,
  BluetoothCharacteristic characteristic,
  String blobName,
  Uint8List data, {
  int? forcedMaxPayload,
  //Duration interChunkDelay = const Duration(milliseconds: 70),
}) async {
  // ── 1. Negotiate MTU ────────────────────────────────────────────────────
  await device.requestMtu(400);
  await Future.delayed(const Duration(milliseconds: 500));

  final int actualMtu = await device.mtu.first;

  // ATT payload size
  final int maxPayload = forcedMaxPayload ?? (actualMtu - 3);

  debugPrint(
    '[BLE] MTU=$actualMtu | maxPayload=$maxPayload',
  );

  // MessagePack overhead estimate:
  //
  // [
  //   type,
  //   chunk_num,
  //   chunk_len,
  //   binary
  // ]
  //
  // Array header + integers + bin header
  const int chunkFrameOverhead = 16;

  final int effectiveChunkSize = maxPayload - chunkFrameOverhead;

  if (effectiveChunkSize <= 0) {
    throw StateError(
      '[BLE] maxPayload ($maxPayload) too small for overhead ($chunkFrameOverhead)',
    );
  }

  final int totalLength = data.length;
  final int numChunks = (totalLength / effectiveChunkSize).ceil();

  debugPrint(
    '[BLE] Blob: "$blobName" | $totalLength bytes | '
    '$numChunks chunks | chunkSize=$effectiveChunkSize',
  );

  // ── 2. Start-of-transfer frame ──────────────────────────────────────────
  //
  // [
  //   2,
  //   totalLength,
  //   blobName,
  //   numChunks,
  //   effectiveChunkSize
  // ]
  //
  final Uint8List startBytes = serialize([
    2,
    totalLength,
    blobName,
    numChunks,
    effectiveChunkSize
  ]);

  debugPrint(
    '[BLE] Start frame: ${startBytes.length} bytes | limit=$maxPayload',
  );

  if (startBytes.length > maxPayload) {
    throw StateError(
      '[BLE] Start frame (${startBytes.length} bytes) exceeds maxPayload '
      '($maxPayload). Shorten the blob name.',
    );
  }

  try {
    await characteristic.write(
      startBytes,
      withoutResponse: false,
    );

    debugPrint('[BLE] Sent start-of-transfer frame');
  } catch (e) {
    debugPrint('[BLE] Start frame write failed: $e');
    rethrow;
  }

  await Future.delayed(const Duration(milliseconds: 50));

  // ── 3. Chunk frames ─────────────────────────────────────────────────────
  for (int i = 0; i < numChunks; i++) {
    final int start = i * effectiveChunkSize;
    final int end = (start + effectiveChunkSize).clamp(0, totalLength);

    final Uint8List chunk = data.sublist(start, end);

    //
    // [
    //   3,
    //   chunkIndex,
    //   chunkLength,
    //   binaryChunk
    // ]
    //
    final Uint8List chunkBytes = serialize([
      3,
      i,
      chunk.length,
      chunk,
    ]);

    final retries = 30;

    for (var i = 0; i < retries; i++) {
      try {
        await characteristic.write(
          chunkBytes,
          withoutResponse: false,
        );
        break;
      } catch (e) {
        debugPrint('[BLE Write Fail] Chunk $i write failed: $e');
        if (i + 1 >= retries) {
          rethrow;
        }
        debugPrint("[BLE Retrying] Retrying..................");
        await Future.delayed(const Duration(milliseconds: 5000));
      }
    }

    debugPrint(
      '[BLE] Chunk ${i + 1}/$numChunks | '
      'payload=${chunk.length} | wire=${chunkBytes.length}',
    );

    //if (interChunkDelay > Duration.zero && i < numChunks - 1) {
    //  await Future.delayed(interChunkDelay);
    //}
  }

  debugPrint('[BLE] Blob transfer complete: "$blobName"');
}
