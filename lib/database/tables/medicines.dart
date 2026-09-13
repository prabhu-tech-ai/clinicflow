import 'package:drift/drift.dart';

class Medicines extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get form => text().nullable()();
  TextColumn get strength => text().nullable()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
