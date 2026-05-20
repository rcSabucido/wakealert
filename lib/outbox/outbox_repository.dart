import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/outbox_dao.dart';

class OutboxRepository {
  OutboxRepository(this._dao);

  final OutboxDao _dao;

  Future<void> enqueue({
    required String endpoint,
    required String method,
    Map<String, dynamic>? payload,
  }) async {
    await _dao.insertEntry(OutboxEntriesCompanion.insert(
      endpoint: endpoint,
      method: method,
      payload: Value(payload != null ? jsonEncode(payload) : null),
      status: OutboxStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  Future<List<OutboxEntry>> getPending({int limit = 10}) =>
      _dao.getPendingEntries(limit: limit);

  Future<void> markProcessing(int id) => _dao.markAsProcessing(id);

  Future<void> markSuccess(int id) => _dao.markAsSuccess(id);

  Future<void> markFailed(int id, int retryCount) =>
      _dao.markAsFailed(id, retryCount);

  Future<void> resetStuck() => _dao.resetStuckProcessing();
}