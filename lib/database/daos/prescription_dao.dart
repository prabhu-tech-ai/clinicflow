import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/clinic_inputs.dart';
import '../database.dart';

class PrescriptionDao {
  PrescriptionDao(this.db);
  final ClinicDatabase db;
  final _uuid = const Uuid();

  Future<Prescription> save(PrescriptionInput input, {String? id}) async {
    final now = DateTime.now().toUtc();
    final prescriptionId = id ?? _uuid.v4();
    await db.transaction(() async {
      await db.into(db.prescriptions).insertOnConflictUpdate(
            PrescriptionsCompanion.insert(
              id: prescriptionId,
              visitId: input.visitId,
              patientId: input.patientId,
              doctorId: Value(input.doctorId),
              diagnosis: Value(input.diagnosis?.trim()),
              advice: Value(input.advice?.trim()),
              createdAt: now,
              updatedAt: now,
            ),
          );
      if (id != null) {
        await (db.delete(db.prescriptionItems)..where((row) => row.prescriptionId.equals(prescriptionId))).go();
      }
      for (final item in input.items) {
        await db.into(db.prescriptionItems).insert(
              PrescriptionItemsCompanion.insert(
                id: _uuid.v4(),
                prescriptionId: prescriptionId,
                medicineId: item.medicineId,
                dosage: item.dosage,
                frequency: item.frequency,
                duration: item.duration,
                quantity: Value(item.quantity),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
      await db.into(db.syncQueue).insert(
            SyncQueueCompanion.insert(
              id: _uuid.v4(),
              entityType: 'prescription',
              entityId: prescriptionId,
              action: id == null ? 'create' : 'update',
              payload: '{}',
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
    return (await (db.select(db.prescriptions)..where((row) => row.id.equals(prescriptionId))).getSingle());
  }

  Future<void> delete(String id) async => (db.update(db.prescriptions)..where((row) => row.id.equals(id))).write(const PrescriptionsCompanion(isDeleted: Value(true), syncStatus: Value('pending')));
}
