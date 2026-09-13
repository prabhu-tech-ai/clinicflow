import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class UserDao {
  UserDao(this.db);
  final ClinicDatabase db;
  final _uuid = const Uuid();

  static const debugUsername = '001';
  static const debugPassword = '1234';

  Future<User?> authenticate(String username, String password) =>
      (db.select(db.users)
            ..where((row) => row.username.equals(username) & row.password.equals(password) & row.isDeleted.equals(false)))
          .getSingleOrNull();

  Future<User> ensureDemoUser() async {
    final existing = await (db.select(db.users)..where((row) => row.username.equals(debugUsername))).getSingleOrNull();
    if (existing != null) return existing;
    final now = DateTime.now().toUtc();
    await db.into(db.users).insert(
          UsersCompanion.insert(
            id: _uuid.v4(),
            username: debugUsername,
            password: debugPassword,
            role: 'admin',
            displayName: const Value('Admin User'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await (db.select(db.users)..where((row) => row.username.equals(debugUsername))).getSingle());
  }
}
