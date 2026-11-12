import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class AppDatabase {
  static Database? _database;
  static const Uuid _uuid = Uuid();

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static const int _databaseVersion = 3;

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'resqnet.db');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE disaster_events (
            local_id TEXT PRIMARY KEY,
            event_type TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            description TEXT NOT NULL,
            local_created_at TEXT NOT NULL,
            sync_status TEXT NOT NULL DEFAULT 'PENDING',
            status TEXT NOT NULL DEFAULT 'ACTIVE',
            expires_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE emergency_contacts (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            relationship TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE emergency_contacts (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              phone TEXT NOT NULL,
              relationship TEXT,
              created_at TEXT NOT NULL
            )
          ''');
        }

        if (oldVersion < 3) {
          await db.execute(
            "ALTER TABLE disaster_events ADD COLUMN status TEXT NOT NULL DEFAULT 'ACTIVE'",
          );

          await db.execute(
            'ALTER TABLE disaster_events ADD COLUMN expires_at TEXT',
          );
        }
      },
    );
  }

  static Future<int> insertDisasterEvent({
    required String localId,
    required String eventType,
    required double latitude,
    required double longitude,
    required String description,
  }) async {
    final db = await database;

    return await db.insert(
      'disaster_events',
      {
        'local_id': localId,
        'event_type': eventType,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'local_created_at': DateTime.now().toIso8601String(),
        'sync_status': 'PENDING',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String> saveDisasterEvent({
    required String eventType,
    required double latitude,
    required double longitude,
    required String description,
  }) async {
    final localId = _uuid.v4();

    await insertDisasterEvent(
      localId: localId,
      eventType: eventType,
      latitude: latitude,
      longitude: longitude,
      description: description,
    );

    return localId;
  }

  static Future<List<Map<String, Object?>>> getSavedDisasterEvents() async {
    final db = await database;

    return await db.query(
      'disaster_events',
      orderBy: 'local_created_at DESC',
    );
  }

  static Future<List<Map<String, Object?>>> getPendingDisasterEvents() async {
    final db = await database;

    return await db.query(
      'disaster_events',
      where: 'sync_status = ?',
      whereArgs: ['PENDING'],
      orderBy: 'local_created_at ASC',
    );
  }

  static Future<int> markDisasterEventAsSynced(
    String localId,
  ) async {
    final db = await database;

    return await db.update(
      'disaster_events',
      {'sync_status': 'SYNCED'},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  static Future<int> updateReportStatus({
    required String localId,
    required String status,
  }) async {
    final db = await database;

    return await db.update(
      'disaster_events',
      {'status': status},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  static Future<void> debugSavedDisasterEvents() async {
    final events = await getSavedDisasterEvents();

    // ignore: avoid_print
    print('Total saved reports: ${events.length}');

    for (final event in events) {
      // ignore: avoid_print
      print('Saved report: $event');
    }

    debugPrint('Total saved reports: ${events.length}');
  }

  // Save emergency contact
  static Future<String> saveEmergencyContact({
    required String name,
    required String phone,
    String? relationship,
  }) async {
    final db = await database;
    final id = _uuid.v4();

    await db.insert(
      'emergency_contacts',
      {
        'id': id,
        'name': name,
        'phone': phone,
        'relationship': relationship,
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    return id;
  }

  // Get all emergency contacts
  static Future<List<Map<String, Object?>>> getEmergencyContacts() async {
    final db = await database;

    return await db.query(
      'emergency_contacts',
      orderBy: 'created_at DESC',
    );
  }

  // Update emergency contact
  static Future<int> updateEmergencyContact({
    required String id,
    required String name,
    required String phone,
    String? relationship,
  }) async {
    final db = await database;

    return await db.update(
      'emergency_contacts',
      {
        'name': name,
        'phone': phone,
        'relationship': relationship,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete emergency contact
  static Future<int> deleteEmergencyContact(String id) async {
    final db = await database;

    return await db.delete(
      'emergency_contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
