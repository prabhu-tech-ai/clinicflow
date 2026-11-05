import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/clinic_inputs.dart';
import '../../services/sync_payload.dart';
import '../database.dart';
import 'sync_queue_dao.dart';

class PatientDao {
  PatientDao(this.db);
  final ClinicDatabase db;
  final _uuid = const Uuid();
  late final _syncQueue = SyncQueueDao(db);

  Stream<List<Patient>> watchPatients() =>
      (db.select(db.patients)
            ..where((row) => row.isDeleted.equals(false))
            ..orderBy([(row) => OrderingTerm(expression: row.fullName)]))
          .watch();

  Stream<List<Patient>> watchRecentPatients({int limit = 3}) =>
      (db.select(db.patients)
            ..where((row) => row.isDeleted.equals(false))
            ..orderBy([
              (row) => OrderingTerm(
                expression: row.createdAt,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(limit))
          .watch();

  Future<List<Patient>> getPatients() =>
      (db.select(db.patients)
        ..where((row) => row.isDeleted.equals(false))).get();

  Future<Patient?> findById(String id) =>
      (db.select(db.patients)
        ..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<Patient?> findByCode(String code) =>
      (db.select(db.patients)..where(
        (row) => row.patientCode.equals(code) & row.isDeleted.equals(false),
      )).getSingleOrNull();

  Future<Patient?> findByName(String name) =>
      (db.select(db.patients)..where(
        (row) => row.fullName.equals(name) & row.isDeleted.equals(false),
      )).getSingleOrNull();

  Future<Patient> save(PatientInput input, {String? id}) async {
    final now = DateTime.now().toUtc();
    final patientId = id ?? _uuid.v4();
    return db.transaction(() async {
      final existing = id == null ? null : await findById(id);
      final code =
          existing?.patientCode ??
          'P${now.millisecondsSinceEpoch.toString().substring(4)}';
      await db
          .into(db.patients)
          .insertOnConflictUpdate(
            PatientsCompanion.insert(
              id: patientId,
              patientCode: code,
              fullName: input.fullName.trim(),
              mobile: Value(input.mobile?.trim()),
              dateOfBirth: Value(input.dateOfBirth),
              address: Value(input.address?.trim()),
              bloodGroup: Value(input.bloodGroup?.trim()),
              allergies: Value(input.allergies?.trim()),
              medicalHistory: Value(input.medicalHistory?.trim()),
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
            ),
          );
      final saved = await findById(patientId);
      if (saved == null) {
        throw StateError('Patient $patientId was not saved');
      }
      await _syncQueue.enqueue(
        entityType: 'patients',
        entityId: patientId,
        action: id == null ? 'create' : 'update',
        payload: SyncPayload.patient(saved),
      );
      return saved;
    });
  }

  Future<void> delete(String id) async {
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      await (db.update(db.patients)..where((row) => row.id.equals(id))).write(
        PatientsCompanion(
          updatedAt: Value(now),
          isDeleted: const Value(true),
          syncStatus: const Value('pending'),
        ),
      );
      final deleted = await findById(id);
      if (deleted != null) {
        await _syncQueue.enqueue(
          entityType: 'patients',
          entityId: id,
          action: 'delete',
          payload: SyncPayload.patient(deleted),
        );
      }
    });
  }
}
