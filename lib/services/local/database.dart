import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _database;
  final bool inMemory;

  DatabaseService({this.inMemory = false});

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    if (inMemory) {
      path = inMemoryDatabasePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, 'stockmate.db');
    }

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedInitialData(db);
      },
    );
  }

  // CREATE TABLES
  Future<void> _createTables(Database db) async {
    // TABLE ITEMS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        profile_picture_url TEXT,
        role TEXT NOT NULL CHECK (role IN ('admin', 'stockManager', 'kasir')),
        password TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  // SEED INITIAL DATA
  Future<void> _seedInitialData(Database db) async {
    // SEED ITEMS
  }
}
