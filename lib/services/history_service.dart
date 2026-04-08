import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HistoryService {
  static Database? _database;
  static const String _tableName = 'conversion_history';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE $_tableName (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  originalName TEXT NOT NULL,
  targetFormat TEXT NOT NULL,
  resultPath TEXT NOT NULL,
  timestamp TEXT NOT NULL
)
''');
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final db = await database;
      final results = await db.query(_tableName, orderBy: 'timestamp DESC');
      // Convert Map<String, Object?> to Map<String, dynamic>
      return results.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addEntry({
    required String originalName,
    required String targetFormat,
    required String resultPath,
  }) async {
    final db = await database;
    await db.insert(
      _tableName,
      {
        'originalName': originalName,
        'targetFormat': targetFormat,
        'resultPath': resultPath,
        'timestamp': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
