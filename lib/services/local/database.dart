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
    // TABLE USERS
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
    // TABLE PRODUCTS
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        sku TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        min_stock REAL NOT NULL,
        current_stock REAL NOT NULL DEFAULT 0,
        notes TEXT,
        image_path TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    // TABLE STOCK TRANSACTIONS
    await db.execute('''
      CREATE TABLE stock_transactions (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity REAL NOT NULL,
        remaining_quantity REAL NOT NULL,
        expiry_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');
  }

  // SEED INITIAL DATA
  Future<void> _seedInitialData(Database db) async {
    // SEED ITEMS
  }
}
