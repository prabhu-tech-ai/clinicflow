import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/clinic_inputs.dart';
import '../database.dart';

class VisitDao {
  VisitDao(this.db);
  final ClinicDatabase db;
  final _uuid = const Uuid();

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
    await db
        .into(db.syncQueue)
        .insert(
          SyncQueueCompanion.insert(
            id: _uuid.v4(),
            entityType: 'visit',
            entityId: visitId,
            action: id == null ? 'create' : 'update',
            payload: '{}',
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await (db.select(db.visits)
      ..where((row) => row.id.equals(visitId))).getSingle());
  }

  Future<void> delete(String id) async {
    await (db.update(db.visits)..where((row) => row.id.equals(id))).write(
      const VisitsCompanion(
        isDeleted: Value(true),
        syncStatus: Value('pending'),
      ),
    );
  }
}
