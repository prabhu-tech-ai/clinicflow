import 'package:drift/drift.dart';

import 'doctors.dart';
import 'patients.dart';

class Visits extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get doctorId => text().nullable().references(Doctors, #id)();
  TextColumn get visitType => text()();
  DateTimeColumn get visitDate => dateTime()();
  TextColumn get symptoms => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
