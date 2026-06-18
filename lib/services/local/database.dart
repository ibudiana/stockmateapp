import 'dart:math';

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
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
        // await _seedInitialData(db);
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
        phone TEXT,
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
  // SEED INITIAL DATA
  Future<void> seedInitialData() async {
    final db = await database;
    final now = DateTime.now();
    final random = Random();

    await db.transaction((txn) async {
      final List<Map<String, dynamic>> products = [];
      final Map<String, double> stockTracker = {};
      final List<String> productIds = [];

      // 1. GENERATE 20 PRODUK (Stok Awal 0)
      final List<String> baseNames = [
        'Beras',
        'Gula Pasir',
        'Minyak Goreng',
        'Kopi Robusta',
        'Teh Celup',
        'Susu Kental Manis',
        'Tepung Terigu',
        'Mie Instan',
        'Kecap Manis',
        'Saos Sambal',
        'Margarin',
        'Keju Cheddar',
        'Garam Dapur',
        'Kaldu Bubuk',
        'Sarden',
        'Kornet Sapi',
        'Oatmeal',
        'Selai Kacang',
        'Biskuit',
        'Air Mineral',
      ];

      for (int i = 0; i < 20; i++) {
        final id = 'PROD-SEED-${(i + 1).toString().padLeft(3, '0')}';
        productIds.add(id);
        stockTracker[id] = 0.0; // Tetapkan stok di memori 0 terlebih dahulu

        products.add({
          'id': id,
          'sku': 'SKU-${random.nextInt(9000) + 1000}',
          'name': '${baseNames[i]} Premium',
          'unit': ['Kg', 'Pcs', 'Liter', 'Kotak', 'Bks'][random.nextInt(5)],
          'min_stock':
              (random.nextInt(5) + 1) * 10.0, // Minimal stok 10, 20, 30...
          'current_stock': 0.0, // Insert awal 0
          'notes': 'Produk otomatis dari Seeder',
          'image_path': null,
          'is_active': 1,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
      }

      // 2. GENERATE 100 TRANSAKSI (In & Out)
      final List<Map<String, dynamic>> transactions = [];

      for (int i = 0; i < 100; i++) {
        // Ambil produk acak dari 20 produk yang ada
        final productId = productIds[random.nextInt(productIds.length)];

        final bool wantOut = random.nextBool(); // 50/50 Peluang In atau Out
        double currentStock = stockTracker[productId]!;

        String type = 'inStock';
        double qty =
            (random.nextInt(10) + 1) * 5.0; // Jumlah antara 5 sampai 50

        // Jika minta barang keluar, pastikan stoknya cukup
        if (wantOut && currentStock > 0) {
          type = 'outStock';
          if (qty > currentStock) {
            qty = currentStock; // Ambil semua sisa stok agar tidak minus
          }
        } else if (wantOut && currentStock == 0) {
          // Paksa jadi inStock jika stok kosong agar transaksi tidak error
          type = 'inStock';
        }

        // Update tracking memori
        if (type == 'inStock') {
          stockTracker[productId] = currentStock + qty;
        } else {
          stockTracker[productId] = currentStock - qty;
        }

        // Buat expiry date berbeda-beda khusus untuk barang masuk (30 s/d 365 hari ke depan)
        String? expiryDate;
        if (type == 'inStock') {
          expiryDate = now
              .add(Duration(days: random.nextInt(335) + 30))
              .toIso8601String();
        }

        // Waktu transaksi diurutkan agar logis (dari 100 hari lalu hingga hari ini)
        final transactionDate = now.subtract(
          Duration(days: 100 - i, hours: random.nextInt(24)),
        );

        transactions.add({
          'id': 'TRX-SEED-${(i + 1).toString().padLeft(4, '0')}',
          'product_id': productId,
          'type': type,
          'quantity': qty,
          'remaining_quantity':
              stockTracker[productId], // Rekam sisa stok saat transaksi terjadi
          'expiry_date': expiryDate,
          'notes': type == 'inStock'
              ? 'Barang masuk (Batch ${random.nextInt(900) + 100})'
              : 'Terjual/Keluar',
          'created_at': transactionDate.toIso8601String(),
        });
      }

      // 3. SINKRONISASI AKHIR STOK KE TABEL PRODUK
      // Perbarui current_stock di list produk sebelum dimasukkan ke SQLite
      for (int i = 0; i < products.length; i++) {
        products[i]['current_stock'] = stockTracker[products[i]['id']];
      }

      // 4. EKSEKUSI INSERT KE SQLITE
      for (var p in products) {
        await txn.insert(
          'products',
          p,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (var t in transactions) {
        await txn.insert(
          'stock_transactions',
          t,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
