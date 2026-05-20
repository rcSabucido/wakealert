// lib/outbox/connectivity_outbox.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'outbox_processor.dart';

/// Wraps the processor and pauses it when the device is offline.
class ConnectivityOutbox {
  ConnectivityOutbox({
    required OutboxProcessor processor,
    Connectivity? connectivity,          // injectable for tests
  })  : _processor = processor,
        _connectivity = connectivity ?? Connectivity() {
    _listen();
  }

  final OutboxProcessor _processor;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  void _listen() {
    // initial state
    _connectivity.checkConnectivity().then(_handle);

    // changes
    _sub = _connectivity.onConnectivityChanged.listen(_handle);
  }

  void _handle(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    online ? _processor.start() : _processor.stop();
  }

  void dispose() {
    _sub?.cancel();
    _processor.stop();
  }
}