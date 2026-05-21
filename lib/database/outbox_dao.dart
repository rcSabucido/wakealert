// lib/database/outbox_dao.dart
import 'package:drift/drift.dart';
import 'database.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [OutboxEntries])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  Future<int> insertEntry(OutboxEntriesCompanion entry) =>
      into(outboxEntries).insert(entry);

  Future<List<OutboxEntry>> getPendingEntries({int limit = 10}) =>
      (select(outboxEntries)
            ..where((e) => e.status.equalsValue(OutboxStatus.pending))
            ..orderBy([(e) => OrderingTerm.asc(e.createdAt)])
            ..limit(limit))
          .get();

  Future<int> clearAll() => delete(outboxEntries).go();

  Future<void> markAsProcessing(int id) => (update(outboxEntries)
        ..where((e) => e.id.equals(id)))
      .write(OutboxEntriesCompanion(
        status: const Value(OutboxStatus.processing),
        updatedAt: Value(DateTime.now()),
      ));

  Future<void> markAsSuccess(int id) =>
      (delete(outboxEntries)..where((e) => e.id.equals(id))).go();

  Future<void> markAsFailed(int id, int retryCount) =>
      (update(outboxEntries)..where((e) => e.id.equals(id))).write(
        OutboxEntriesCompanion(
          status: Value(
            retryCount >= 1000000000 ? OutboxStatus.failed : OutboxStatus.pending,
          ),
          retryCount: Value(retryCount + 1),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> resetStuckProcessing() =>
      (update(outboxEntries)
            ..where((e) => e.status.equalsValue(OutboxStatus.processing)))
          .write(OutboxEntriesCompanion(
        status: const Value(OutboxStatus.pending),
        updatedAt: Value(DateTime.now()),
      ));
}