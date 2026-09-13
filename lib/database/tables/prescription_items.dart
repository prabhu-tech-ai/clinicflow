import 'package:drift/drift.dart';

import 'medicines.dart';
import 'prescriptions.dart';

class PrescriptionItems extends Table {
  TextColumn get id => text()();
  TextColumn get prescriptionId => text().references(Prescriptions, #id)();
  TextColumn get medicineId => text().references(Medicines, #id)();
  TextColumn get dosage => text()();
  TextColumn get frequency => text()();
  TextColumn get duration => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
