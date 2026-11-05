import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class SyncQueueDao {
  SyncQueueDao(this.db);

  final ClinicDatabase db;
  final _uuid = const Uuid();

  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required String action,
    required Map<String, Object?> payload,
  }) async {
    final now = DateTime.now().toUtc();
    await (db.delete(db.syncQueue)..where(
      (row) =>
          row.entityType.equals(entityType) &
          row.entityId.equals(entityId) &
          row.status.isIn(['pending', 'failed']),
    )).go();
    await db
        .into(db.syncQueue)
        .insert(
          SyncQueueCompanion.insert(
            id: _uuid.v4(),
            entityType: entityType,
            entityId: entityId,
            action: action,
            payload: jsonEncode(payload),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }
}
