import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../database/daos/sync_queue_dao.dart';
import 'sync_payload.dart';

class FirebaseSyncService {
  FirebaseSyncService(this._database) : _syncQueue = SyncQueueDao(_database);

  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _databaseUrl = String.fromEnvironment('FIREBASE_DATABASE_URL');
  static const _clinicId = String.fromEnvironment('FIREBASE_CLINIC_ID');
  static const _uuid = Uuid();

  final ClinicDatabase _database;
  final SyncQueueDao _syncQueue;
  final ValueNotifier<String?> lastError = ValueNotifier(null);
  FirebaseDatabase? _firebaseDatabase;
  StreamSubscription<DatabaseEvent>? _connectionSubscription;
  StreamSubscription<List<SyncQueueData>>? _queueSubscription;
  bool _connected = false;
  bool _syncing = false;
  bool _initialized = false;

  bool get isConfigured =>
      _apiKey.isNotEmpty &&
      _appId.isNotEmpty &&
      _messagingSenderId.isNotEmpty &&
      _projectId.isNotEmpty &&
      _databaseUrl.isNotEmpty &&
      _clinicId.isNotEmpty;

  Future<void> dispose() async {
    await _connectionSubscription?.cancel();
    await _queueSubscription?.cancel();
    lastError.dispose();
  }

  String get status {
    if (!isConfigured) {
      return 'Firebase is not configured; data is being saved on this device.';
    }
    final error = lastError.value;
    if (error != null) return error;
    return _connected
        ? 'Firebase is connected and local changes sync automatically.'
        : 'Waiting for a Firebase connection.';
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (!isConfigured) {
      debugPrint(status);
      return;
    }

    try {
      final app = await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: _apiKey,
          appId: _appId,
          messagingSenderId: _messagingSenderId,
          projectId: _projectId,
          databaseURL: _databaseUrl,
        ),
      );
      final firebaseDatabase = FirebaseDatabase.instanceFor(
        app: app,
        databaseURL: _databaseUrl,
      );
      _firebaseDatabase = firebaseDatabase;
      await _queueExistingData();
      _connectionSubscription = firebaseDatabase
          .ref('.info/connected')
          .onValue
          .listen(
            (event) {
              final connected = event.snapshot.value == true;
              final reconnected = connected && !_connected;
              _connected = connected;
              if (reconnected) {
                unawaited(_handleReconnect());
              } else if (_connected) {
                unawaited(_flush());
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              _reportError('Firebase connection status failed', error);
            },
          );
      _queueSubscription = (_database.select(_database.syncQueue)
            ..where((row) => row.status.equals('pending'))
            ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
          .watch()
          .listen(
            (_) {
              if (_connected) unawaited(_flush());
            },
            onError: (Object error, StackTrace stackTrace) {
              _reportError('Local sync queue could not be read', error);
            },
          );
    } on FirebaseException catch (error) {
      _reportError('Firebase initialization failed', error);
    } on PlatformException catch (error) {
      _reportError('Firebase initialization failed', error);
    } on UnsupportedError catch (error) {
      _reportError('Firebase is unavailable on this platform', error);
    } on Exception catch (error) {
      _reportError('Firebase initialization failed', error);
    }
  }

  Future<void> retryFailed() async {
    await _retryFailedWrites();
    if (_connected) await _flush();
  }

  Future<void> _retryFailedWrites() async {
    await (_database.update(_database.syncQueue)
      ..where((row) => row.status.equals('failed'))).write(
      SyncQueueCompanion(
        status: const Value('pending'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    lastError.value = null;
  }

  Future<void> _handleReconnect() async {
    await _retryFailedWrites();
    await _flush();
  }

  Future<int> pendingCount() async => (_database.select(_database.syncQueue)
    ..where(
      (row) => row.status.isIn(['pending', 'failed']),
    )).get().then((rows) => rows.length);

  Future<void> _queueExistingData() async {
    await _database.transaction(() async {
      final initialized =
          await (_database.select(_database.syncQueue)..where(
            (row) =>
                row.entityType.equals('_bootstrap') &
                row.entityId.equals('initial-data'),
          )).getSingleOrNull();
      if (initialized != null) return;

      for (final row in await _database.select(_database.patients).get()) {
        await _syncQueue.enqueue(
          entityType: 'patients',
          entityId: row.id,
          action: 'snapshot',
          payload: SyncPayload.patient(row),
        );
      }
      for (final row in await _database.select(_database.visits).get()) {
        await _syncQueue.enqueue(
          entityType: 'visits',
          entityId: row.id,
          action: 'snapshot',
          payload: SyncPayload.visit(row),
        );
      }
      for (final row in await _database.select(_database.medicines).get()) {
        await _syncQueue.enqueue(
          entityType: 'medicines',
          entityId: row.id,
          action: 'snapshot',
          payload: SyncPayload.medicine(row),
        );
      }
      for (final row in await _database.select(_database.doctors).get()) {
        await _syncQueue.enqueue(
          entityType: 'doctors',
          entityId: row.id,
          action: 'snapshot',
          payload: SyncPayload.doctor(row),
        );
      }
      for (final row in await _database.select(_database.employees).get()) {
        await _syncQueue.enqueue(
          entityType: 'employees',
          entityId: row.id,
          action: 'snapshot',
          payload: SyncPayload.employee(row),
        );
      }
      for (final row in await _database.select(_database.prescriptions).get()) {
        final items =
            await (_database.select(_database.prescriptionItems)
              ..where((item) => item.prescriptionId.equals(row.id))).get();
        await _syncQueue.enqueue(
          entityType: 'prescriptions',
          entityId: row.id,
          action: 'snapshot',
          payload: SyncPayload.prescription(row, items),
        );
      }
      for (final row in await _database.select(_database.users).get()) {
        await _syncQueue.enqueue(
          entityType: 'users',
          entityId: row.id,
          action: 'snapshot',
          payload: SyncPayload.user(row),
        );
      }
      for (final row in await _database.select(_database.auditLogs).get()) {
        await _syncQueue.enqueue(
          entityType: 'auditLogs',
          entityId: row.id,
          action: 'snapshot',
          payload: SyncPayload.auditLog(row),
        );
      }
      final now = DateTime.now().toUtc();
      await _database
          .into(_database.syncQueue)
          .insert(
            SyncQueueCompanion.insert(
              id: _uuid.v4(),
              entityType: '_bootstrap',
              entityId: 'initial-data',
              action: 'complete',
              payload: '{}',
              status: const Value('done'),
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
  }

  Future<void> _flush() async {
    final firebaseDatabase = _firebaseDatabase;
    if (!_connected || _syncing || firebaseDatabase == null) return;

    _syncing = true;
    try {
      final pending =
          await (_database.select(_database.syncQueue)
                ..where((row) => row.status.equals('pending'))
                ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
              .get();
      for (final item in pending) {
        try {
          final decoded = jsonDecode(item.payload);
          if (decoded is! Map<String, dynamic>) {
            throw const FormatException('Sync payload must be a JSON object');
          }
          if (decoded.isEmpty) {
            await (_database.delete(_database.syncQueue)
              ..where((row) => row.id.equals(item.id))).go();
            continue;
          }
          await firebaseDatabase
              .ref(
                'clinics/$_clinicId/data/${item.entityType}/${item.entityId}',
              )
              .set(decoded);
          await (_database.delete(_database.syncQueue)
            ..where((row) => row.id.equals(item.id))).go();
        } on FirebaseException catch (error) {
          await _markFailed(item, error);
        } on PlatformException catch (error) {
          await _markFailed(item, error);
        } on FormatException catch (error) {
          await _markFailed(item, error);
        } on UnsupportedError catch (error) {
          await _markFailed(item, error);
        }
      }
      final failed =
          await (_database.select(_database.syncQueue)
            ..where((row) => row.status.equals('failed'))).get();
      if (failed.isEmpty) lastError.value = null;
    } on FirebaseException catch (error) {
      _reportError('Firebase sync failed', error);
    } on PlatformException catch (error) {
      _reportError('Firebase sync failed', error);
    } on UnsupportedError catch (error) {
      _reportError('Firebase sync is unavailable on this platform', error);
    } finally {
      _syncing = false;
      if (_connected) unawaited(_flushPendingWrites());
    }
  }

  Future<void> _flushPendingWrites() async {
    final pending =
        await (_database.select(_database.syncQueue)
          ..where((row) => row.status.equals('pending'))).getSingleOrNull();
    if (pending != null) await _flush();
  }

  Future<void> _markFailed(SyncQueueData item, Object error) async {
    final now = DateTime.now().toUtc();
    await (_database.update(_database.syncQueue)
      ..where((row) => row.id.equals(item.id))).write(
      SyncQueueCompanion(
        status: const Value('failed'),
        attempts: Value(item.attempts + 1),
        updatedAt: Value(now),
      ),
    );
    _reportError(
      'Could not sync ${item.entityType}/${item.entityId}: $error',
      error,
    );
  }

  void _reportError(String context, Object error) {
    final message = '$context: $error';
    lastError.value = message;
    debugPrint(message);
  }
}

final firebaseSyncService = FirebaseSyncService(clinicDatabase);
