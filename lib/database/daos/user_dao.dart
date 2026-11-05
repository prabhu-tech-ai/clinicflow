import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../services/sync_payload.dart';
import '../database.dart';
import 'sync_queue_dao.dart';

class UserDao {
  UserDao(this.db);
  final ClinicDatabase db;
  final _uuid = const Uuid();
  late final _syncQueue = SyncQueueDao(db);

  static const debugUsername = '001';
  static const debugPassword = '1234';

  Future<User?> authenticate(String username, String password) =>
      (db.select(db.users)..where(
        (row) =>
            row.username.equals(username) &
            row.password.equals(password) &
            row.isDeleted.equals(false),
      )).getSingleOrNull();

  Future<User> ensureDemoUser() async {
    final existing =
        await (db.select(db.users)..where(
          (row) => row.username.equals(debugUsername),
        )).getSingleOrNull();
    if (existing != null) return existing;
    final now = DateTime.now().toUtc();
    return db.transaction(() async {
      await db
          .into(db.users)
          .insert(
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
      final user =
          await (db.select(db.users)
            ..where((row) => row.username.equals(debugUsername))).getSingle();
      await _syncQueue.enqueue(
        entityType: 'users',
        entityId: user.id,
        action: 'create',
        payload: SyncPayload.user(user),
      );
      return user;
    });
  }
}
