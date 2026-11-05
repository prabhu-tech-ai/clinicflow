import 'dart:convert';

import 'package:clinicflow/database/daos/patient_dao.dart';
import 'package:clinicflow/database/database.dart';
import 'package:clinicflow/models/clinic_inputs.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ClinicDatabase database;

  setUp(() {
    database = ClinicDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'patient data and sync payload are committed locally together',
    () async {
      final saved = await PatientDao(
        database,
      ).save(const PatientInput(fullName: 'Test Patient', mobile: '5550100'));
      final local =
          await (database.select(database.patients)
            ..where((row) => row.id.equals(saved.id))).getSingle();
      final queue =
          await (database.select(database.syncQueue)
            ..where((row) => row.entityId.equals(saved.id))).getSingle();
      final payload = jsonDecode(queue.payload) as Map<String, dynamic>;

      expect(local.fullName, 'Test Patient');
      expect(queue.entityType, 'patients');
      expect(payload['fullName'], 'Test Patient');
      expect(payload['mobile'], '5550100');
    },
  );
}
