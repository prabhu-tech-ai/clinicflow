import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/clinic_inputs.dart';
import '../database.dart';

class PatientDao {
  PatientDao(this.db);
  final ClinicDatabase db;
  final _uuid = const Uuid();

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
    await db
        .into(db.syncQueue)
        .insert(
          SyncQueueCompanion.insert(
            id: _uuid.v4(),
            entityType: 'patient',
            entityId: patientId,
            action: id == null ? 'create' : 'update',
            payload: '{}',
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await findById(patientId))!;
  }

  Future<void> delete(String id) async {
    final now = DateTime.now().toUtc();
    await (db.update(db.patients)..where((row) => row.id.equals(id))).write(
      PatientsCompanion(
        updatedAt: Value(now),
        isDeleted: const Value(true),
        syncStatus: const Value('pending'),
      ),
    );
  }
}
