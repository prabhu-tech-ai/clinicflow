import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/clinic_inputs.dart';
import '../../services/sync_payload.dart';
import '../database.dart';
import 'sync_queue_dao.dart';

class MedicineDao {
  MedicineDao(this.db);
  final ClinicDatabase db;
  final _uuid = const Uuid();
  late final _syncQueue = SyncQueueDao(db);

  Stream<List<Medicine>> watchMedicines() =>
      (db.select(db.medicines)
            ..where((row) => row.isDeleted.equals(false))
            ..orderBy([(row) => OrderingTerm(expression: row.name)]))
          .watch();

  Future<Medicine?> findByName(String name) =>
      (db.select(db.medicines)..where(
        (row) => row.name.equals(name) & row.isDeleted.equals(false),
      )).getSingleOrNull();

  Future<Medicine> save(MedicineInput input, {String? id}) async {
    final now = DateTime.now().toUtc();
    final medicineId = id ?? _uuid.v4();
    return db.transaction(() async {
      final existing =
          id == null
              ? null
              : await (db.select(db.medicines)
                ..where((row) => row.id.equals(id))).getSingleOrNull();
      await db
          .into(db.medicines)
          .insertOnConflictUpdate(
            MedicinesCompanion.insert(
              id: medicineId,
              name: input.name.trim(),
              form: Value(input.form?.trim()),
              strength: Value(input.strength?.trim()),
              stock: Value(input.stock),
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
            ),
          );
      final saved =
          await (db.select(db.medicines)
            ..where((row) => row.id.equals(medicineId))).getSingle();
      await _syncQueue.enqueue(
        entityType: 'medicines',
        entityId: medicineId,
        action: id == null ? 'create' : 'update',
        payload: SyncPayload.medicine(saved),
      );
      return saved;
    });
  }

  Future<void> delete(String id) async {
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      await (db.update(db.medicines)..where((row) => row.id.equals(id))).write(
        MedicinesCompanion(
          isDeleted: const Value(true),
          syncStatus: const Value('pending'),
          updatedAt: Value(now),
        ),
      );
      final deleted =
          await (db.select(db.medicines)
            ..where((row) => row.id.equals(id))).getSingleOrNull();
      if (deleted != null) {
        await _syncQueue.enqueue(
          entityType: 'medicines',
          entityId: id,
          action: 'delete',
          payload: SyncPayload.medicine(deleted),
        );
      }
    });
  }
}
