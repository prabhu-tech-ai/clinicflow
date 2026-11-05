import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/clinic_inputs.dart';
import '../../services/sync_payload.dart';
import '../database.dart';
import 'sync_queue_dao.dart';

class VisitDao {
  VisitDao(this.db);
  final ClinicDatabase db;
  final _uuid = const Uuid();
  late final _syncQueue = SyncQueueDao(db);

  Stream<List<Visit>> watchForPatient(String patientId) =>
      (db.select(db.visits)
            ..where(
              (row) =>
                  row.patientId.equals(patientId) & row.isDeleted.equals(false),
            )
            ..orderBy([
              (row) => OrderingTerm(
                expression: row.visitDate,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  Stream<List<Visit>> watchVisits() =>
      (db.select(db.visits)
            ..where((row) => row.isDeleted.equals(false))
            ..orderBy([
              (row) => OrderingTerm(
                expression: row.visitDate,
                mode: OrderingMode.desc,
              ),
            ]))
          .watch();

  Future<Visit> save(VisitInput input, {String? id}) async {
    final now = DateTime.now().toUtc();
    final visitId = id ?? _uuid.v4();
    return db.transaction(() async {
      await db
          .into(db.visits)
          .insertOnConflictUpdate(
            VisitsCompanion.insert(
              id: visitId,
              patientId: input.patientId,
              doctorId: Value(input.doctorId),
              visitType: input.visitType,
              visitDate: input.visitDate.toUtc(),
              symptoms: Value(input.symptoms?.trim()),
              notes: Value(input.notes?.trim()),
              createdAt: now,
              updatedAt: now,
            ),
          );
      final saved =
          await (db.select(db.visits)
            ..where((row) => row.id.equals(visitId))).getSingle();
      await _syncQueue.enqueue(
        entityType: 'visits',
        entityId: visitId,
        action: id == null ? 'create' : 'update',
        payload: SyncPayload.visit(saved),
      );
      return saved;
    });
  }

  Future<void> delete(String id) async {
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      await (db.update(db.visits)..where((row) => row.id.equals(id))).write(
        VisitsCompanion(
          isDeleted: const Value(true),
          syncStatus: const Value('pending'),
          updatedAt: Value(now),
        ),
      );
      final deleted =
          await (db.select(db.visits)
            ..where((row) => row.id.equals(id))).getSingleOrNull();
      if (deleted != null) {
        await _syncQueue.enqueue(
          entityType: 'visits',
          entityId: id,
          action: 'delete',
          payload: SyncPayload.visit(deleted),
        );
      }
    });
  }
}
