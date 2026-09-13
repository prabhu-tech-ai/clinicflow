import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class StaffDao {
  StaffDao(this.db);
  final ClinicDatabase db;
  final _uuid = const Uuid();

  Stream<List<Doctor>> watchDoctors() => (db.select(db.doctors)..where((row) => row.isDeleted.equals(false))..orderBy([(row) => OrderingTerm(expression: row.fullName)])).watch();
  Stream<List<Employee>> watchEmployees() => (db.select(db.employees)..where((row) => row.isDeleted.equals(false))..orderBy([(row) => OrderingTerm(expression: row.fullName)])).watch();

  Future<Doctor> saveDoctor({String? id, required String fullName, String? specialization, String? phone, String? email}) async {
    final now = DateTime.now().toUtc();
    final doctorId = id ?? _uuid.v4();
    final existing = id == null ? null : await (db.select(db.doctors)..where((row) => row.id.equals(id))).getSingleOrNull();
    await db.into(db.doctors).insertOnConflictUpdate(DoctorsCompanion.insert(id: doctorId, fullName: fullName.trim(), specialization: Value(specialization?.trim()), phone: Value(phone?.trim()), email: Value(email?.trim()), createdAt: existing?.createdAt ?? now, updatedAt: now));
    return (await (db.select(db.doctors)..where((row) => row.id.equals(doctorId))).getSingle());
  }

  Future<Employee> saveEmployee({String? id, required String fullName, String? jobTitle, String? phone, String? email}) async {
    final now = DateTime.now().toUtc();
    final employeeId = id ?? _uuid.v4();
    final existing = id == null ? null : await (db.select(db.employees)..where((row) => row.id.equals(id))).getSingleOrNull();
    await db.into(db.employees).insertOnConflictUpdate(EmployeesCompanion.insert(id: employeeId, fullName: fullName.trim(), jobTitle: Value(jobTitle?.trim()), phone: Value(phone?.trim()), email: Value(email?.trim()), createdAt: existing?.createdAt ?? now, updatedAt: now));
    return (await (db.select(db.employees)..where((row) => row.id.equals(employeeId))).getSingle());
  }

  Future<void> deleteDoctor(String id) => (db.update(db.doctors)..where((row) => row.id.equals(id))).write(const DoctorsCompanion(isDeleted: Value(true), syncStatus: Value('pending')));
  Future<void> deleteEmployee(String id) => (db.update(db.employees)..where((row) => row.id.equals(id))).write(const EmployeesCompanion(isDeleted: Value(true), syncStatus: Value('pending')));
}
