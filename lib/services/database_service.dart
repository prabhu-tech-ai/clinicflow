import '../database/database.dart';

class DatabaseService {
  const DatabaseService(this.database);
  final ClinicDatabase database;

  Future<void> close() => database.close();
}

final databaseService = DatabaseService(clinicDatabase);