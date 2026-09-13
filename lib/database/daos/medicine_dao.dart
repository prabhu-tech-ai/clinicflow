import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/clinic_inputs.dart';
import '../database.dart';

class MedicineDao {
  MedicineDao(this.db);
  final ClinicDatabase db;
  final _uuid = const Uuid();

  Stream<List<Medicine>> watchMedicines() => (db.select(db.medicines)
        ..where((row) => row.isDeleted.equals(false))
        ..orderBy([(row) => OrderingTerm(expression: row.name)]))
      .watch();

  Future<Medicine?> findByName(String name) => (db.select(db.medicines)..where((row) => row.name.equals(name) & row.isDeleted.equals(false))).getSingleOrNull();

  Future<Medicine> save(MedicineInput input, {String? id}) async {
    final now = DateTime.now().toUtc();
    final medicineId = id ?? _uuid.v4();
    final existing = id == null ? null : await (db.select(db.medicines)..where((row) => row.id.equals(id))).getSingleOrNull();
    await db.into(db.medicines).insertOnConflictUpdate(
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
    return (await (db.select(db.medicines)..where((row) => row.id.equals(medicineId))).getSingle());
  }

  Future<void> delete(String id) async => (db.update(db.medicines)..where((row) => row.id.equals(id))).write(const MedicinesCompanion(isDeleted: Value(true), syncStatus: Value('pending')));
}
