import 'package:drift/drift.dart';

import 'doctors.dart';
import 'patients.dart';
import 'visits.dart';

class Prescriptions extends Table {
  TextColumn get id => text()();
  TextColumn get visitId => text().unique().references(Visits, #id)();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get doctorId => text().nullable().references(Doctors, #id)();
  TextColumn get diagnosis => text().nullable()();
  TextColumn get advice => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
