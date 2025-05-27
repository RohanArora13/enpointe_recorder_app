import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../app/app.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'enpointe_audio.db';
  static const String _tableName = 'recordings';
  static const int _databaseVersion = 1;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();

  // Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    // Get external storage directory, fallback to documents directory
    Directory? externalDir = await getExternalStorageDirectory();
    externalDir ??= await getApplicationDocumentsDirectory();

    final String path = join(externalDir.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        unique_id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        record_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_format TEXT NOT NULL,
        total_time INTEGER NOT NULL
      )
    ''');
  }

  // Insert a recording into the database
  Future<bool> insertRecording(RecordingModel recording) async {
    try {
      final db = await database;
      await db.insert(
        _tableName,
        recording.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      // Log error if needed
      print('Error inserting recording: $e');
      return false;
    }
  }

  // Get all recordings from the database
  Future<List<RecordingModel>?> getAllRecordings() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'timestamp DESC', // Most recent first
      );

      // Return null if no recordings found
      if (maps.isEmpty) {
        return null;
      }

      return List.generate(maps.length, (i) {
        return RecordingModel.fromJson(maps[i]);
      });
    } catch (e) {
      // Log error if needed
      print('Error getting all recordings: $e');
      return null;
    }
  }

  // Get a specific recording by unique ID
  Future<RecordingModel?> getRecordingById(String uniqueId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'unique_id = ?',
      whereArgs: [uniqueId],
    );

    if (maps.isNotEmpty) {
      return RecordingModel.fromJson(maps.first);
    }
    return null;
  }

  // Get total number of recordings in the database
  Future<int> getTotalRecordingsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Update a recording
  Future<void> updateRecording(RecordingModel recording) async {
    final db = await database;
    await db.update(
      _tableName,
      recording.toJson(),
      where: 'unique_id = ?',
      whereArgs: [recording.uniqueId],
    );
  }

  // Delete a recording by unique ID
  Future<void> deleteRecording(String uniqueId) async {
    final db = await database;
    await db.delete(_tableName, where: 'unique_id = ?', whereArgs: [uniqueId]);
  }

  // Delete all recordings
  Future<void> deleteAllRecordings() async {
    final db = await database;
    await db.delete(_tableName);
  }

  // Get recordings by date range
  Future<List<RecordingModel>> getRecordingsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return RecordingModel.fromJson(maps[i]);
    });
  }

  // Search recordings by name
  Future<List<RecordingModel>> searchRecordingsByName(String searchTerm) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'record_name LIKE ?',
      whereArgs: ['%$searchTerm%'],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return RecordingModel.fromJson(maps[i]);
    });
  }

  // Get recordings by file format
  Future<List<RecordingModel>> getRecordingsByFormat(String format) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'file_format = ?',
      whereArgs: [format],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return RecordingModel.fromJson(maps[i]);
    });
  }

  // Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // Get database path (for debugging purposes)
  Future<String> getDatabasePath() async {
    Directory? externalDir = await getExternalStorageDirectory();
    externalDir ??= await getApplicationDocumentsDirectory();
    return join(externalDir.path, _databaseName);
  }
}
