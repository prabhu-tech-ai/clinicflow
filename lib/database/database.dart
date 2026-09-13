import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/audit_logs.dart';
import 'tables/doctors.dart';
import 'tables/employees.dart';
import 'tables/medicines.dart';
import 'tables/patients.dart';
import 'tables/prescription_items.dart';
import 'tables/prescriptions.dart';
import 'tables/sync_queue.dart';
import 'tables/users.dart';
import 'tables/visits.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Doctors,
    Employees,
    Patients,
    Visits,
    Medicines,
    Prescriptions,
    PrescriptionItems,
    SyncQueue,
    AuditLogs,
  ],
)
class ClinicDatabase extends _$ClinicDatabase {
  ClinicDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 1) {
            await m.createAll();
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'clinicflow.sqlite'));
      return NativeDatabase.createInBackground(file);
    });

final clinicDatabase = ClinicDatabase();
