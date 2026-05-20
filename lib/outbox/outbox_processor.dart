// lib/outbox/outbox_processor.dart
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'outbox_repository.dart';

class OutboxProcessor {
  OutboxProcessor({
    required OutboxRepository repository,
    required Dio dio,
    this.pollInterval = const Duration(seconds: 5),
  })  : _repository = repository,
        _dio = dio;

  final OutboxRepository _repository;
  final Dio _dio;
  final Duration pollInterval;

  Timer? _timer;
  bool _isProcessing = false;

  void start() {
    // Reset any entries stuck in "processing" from a previous crash
    _repository.resetStuck();

    _timer = Timer.periodic(pollInterval, (_) => _process());
    _process(); // run immediately on start
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _process() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final entries = await _repository.getPending();

      for (final entry in entries) {
        await _send(entry);
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _send(entry) async {
    await _repository.markProcessing(entry.id);

    try {
      final data =
          entry.payload != null ? jsonDecode(entry.payload!) : null;

      debugPrint("outbox_processor: New Data! ${data}");

      /*
      await switch (entry.method.toUpperCase()) {
        'POST' => _dio.post(entry.endpoint, data: data),
        'PUT' => _dio.put(entry.endpoint, data: data),
        'PATCH' => _dio.patch(entry.endpoint, data: data),
        'DELETE' => _dio.delete(entry.endpoint),
        _ => throw UnsupportedError('Method ${entry.method} not supported'),
      };
      */

      await _repository.markSuccess(entry.id);
    } on DioException catch (e) {
      // Retry on network/server errors, skip on 4xx client errors
      final shouldRetry = e.response == null ||
          (e.response!.statusCode ?? 0) >= 500;

      if (shouldRetry) {
        await _repository.markFailed(entry.id, entry.retryCount);
      } else {
        await _repository.markSuccess(entry.id); // discard unretryable
      }
    } catch (_) {
      await _repository.markFailed(entry.id, entry.retryCount);
    }
  }
}