import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../services/sync_payload.dart';
import '../database.dart';
import 'sync_queue_dao.dart';

class StaffDao {
  StaffDao(this.db);
  final ClinicDatabase db;
  final _uuid = const Uuid();
  late final _syncQueue = SyncQueueDao(db);

  Stream<List<Doctor>> watchDoctors() =>
      (db.select(db.doctors)
            ..where((row) => row.isDeleted.equals(false))
            ..orderBy([(row) => OrderingTerm(expression: row.fullName)]))
          .watch();
  Stream<List<Employee>> watchEmployees() =>
      (db.select(db.employees)
            ..where((row) => row.isDeleted.equals(false))
            ..orderBy([(row) => OrderingTerm(expression: row.fullName)]))
          .watch();

  Future<Doctor> saveDoctor({
    String? id,
    required String fullName,
    String? specialization,
    String? phone,
    String? email,
  }) async {
    final now = DateTime.now().toUtc();
    final doctorId = id ?? _uuid.v4();
    return db.transaction(() async {
      final existing =
          id == null
              ? null
              : await (db.select(db.doctors)
                ..where((row) => row.id.equals(id))).getSingleOrNull();
      await db
          .into(db.doctors)
          .insertOnConflictUpdate(
            DoctorsCompanion.insert(
              id: doctorId,
              fullName: fullName.trim(),
              specialization: Value(specialization?.trim()),
              phone: Value(phone?.trim()),
              email: Value(email?.trim()),
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
            ),
          );
      final saved =
          await (db.select(db.doctors)
            ..where((row) => row.id.equals(doctorId))).getSingle();
      await _syncQueue.enqueue(
        entityType: 'doctors',
        entityId: doctorId,
        action: id == null ? 'create' : 'update',
        payload: SyncPayload.doctor(saved),
      );
      return saved;
    });
  }

  Future<Employee> saveEmployee({
    String? id,
    required String fullName,
    String? jobTitle,
    String? phone,
    String? email,
  }) async {
    final now = DateTime.now().toUtc();
    final employeeId = id ?? _uuid.v4();
    return db.transaction(() async {
      final existing =
          id == null
              ? null
              : await (db.select(db.employees)
                ..where((row) => row.id.equals(id))).getSingleOrNull();
      await db
          .into(db.employees)
          .insertOnConflictUpdate(
            EmployeesCompanion.insert(
              id: employeeId,
              fullName: fullName.trim(),
              jobTitle: Value(jobTitle?.trim()),
              phone: Value(phone?.trim()),
              email: Value(email?.trim()),
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
            ),
          );
      final saved =
          await (db.select(db.employees)
            ..where((row) => row.id.equals(employeeId))).getSingle();
      await _syncQueue.enqueue(
        entityType: 'employees',
        entityId: employeeId,
        action: id == null ? 'create' : 'update',
        payload: SyncPayload.employee(saved),
      );
      return saved;
    });
  }

  Future<void> deleteDoctor(String id) async {
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      await (db.update(db.doctors)..where((row) => row.id.equals(id))).write(
        DoctorsCompanion(
          isDeleted: const Value(true),
          syncStatus: const Value('pending'),
          updatedAt: Value(now),
        ),
      );
      final deleted =
          await (db.select(db.doctors)
            ..where((row) => row.id.equals(id))).getSingleOrNull();
      if (deleted != null) {
        await _syncQueue.enqueue(
          entityType: 'doctors',
          entityId: id,
          action: 'delete',
          payload: SyncPayload.doctor(deleted),
        );
      }
    });
  }

  Future<void> deleteEmployee(String id) async {
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      await (db.update(db.employees)..where((row) => row.id.equals(id))).write(
        EmployeesCompanion(
          isDeleted: const Value(true),
          syncStatus: const Value('pending'),
          updatedAt: Value(now),
        ),
      );
      final deleted =
          await (db.select(db.employees)
            ..where((row) => row.id.equals(id))).getSingleOrNull();
      if (deleted != null) {
        await _syncQueue.enqueue(
          entityType: 'employees',
          entityId: id,
          action: 'delete',
          payload: SyncPayload.employee(deleted),
        );
      }
    });
  }
}
