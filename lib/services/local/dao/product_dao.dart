import 'package:sqflite/sqflite.dart';
import 'package:stockmateapp/models/product_model.dart';
import 'package:stockmateapp/models/stock_transaction_model.dart';
import 'package:stockmateapp/services/local/database.dart';

class ProductDao {
  final DatabaseService dbService;

  ProductDao({required this.dbService});

  // --- CRUD PRODUK ---
  Future<void> insertProduct(ProductModel product) async {
    final db = await dbService.database;
    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProduct(ProductModel product) async {
    final db = await dbService.database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(String id) async {
    final db = await dbService.database;
    await db.update(
      'products',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ProductModel>> getAllProducts() async {
    final db = await dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return maps.map((map) => ProductModel.fromMap(map)).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    final db = await dbService.database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return ProductModel.fromMap(maps.first);
    return null;
  }

  // --- STOCK TRANSACTIONS ---
  Future<void> addStockTransaction(StockTransactionModel transaction) async {
    final db = await dbService.database;

    await db.transaction((txn) async {
      // LOGIKA FIFO / FEFO (Khusus untuk Stock Keluar)
      if (transaction.type == TransactionType.outStock) {
        double qtyToDeduct = transaction.quantity;

        // 1. Cari semua batch barang masuk yang masih ada sisanya.
        // Diurutkan berdasarkan Expiry Date (FEFO) terdekat. Jika kosong, berdasarkan waktu masuk terlama (FIFO).
        final batches = await txn.query(
          'stock_transactions',
          where: 'product_id = ? AND type = ? AND remaining_quantity > 0',
          whereArgs: [transaction.productId, TransactionType.inStock.name],
          orderBy: 'expiry_date ASC, created_at ASC',
        );

        // 2. Looping untuk memotong sisa stok per batch
        for (var batch in batches) {
          if (qtyToDeduct <= 0)
            break; // Jika sudah terpenuhi, hentikan pemotongan

          double remainingInBatch = (batch['remaining_quantity'] as num)
              .toDouble();
          String batchId = batch['id'] as String;

          if (remainingInBatch <= qtyToDeduct) {
            // Jika sisa di batch ini kurang dari/sama dengan yang mau dikeluarkan: Habiskan batch ini.
            qtyToDeduct -= remainingInBatch;
            await txn.update(
              'stock_transactions',
              {'remaining_quantity': 0},
              where: 'id = ?',
              whereArgs: [batchId],
            );
          } else {
            // Jika sisa di batch ini lebih banyak: Potong sebagian saja.
            await txn.update(
              'stock_transactions',
              {'remaining_quantity': remainingInBatch - qtyToDeduct},
              where: 'id = ?',
              whereArgs: [batchId],
            );
            qtyToDeduct = 0;
          }
        }

        // 3. Validasi Keamanan: Jika setelah loop ternyata stok tidak cukup
        if (qtyToDeduct > 0) {
          throw Exception(
            'Gagal: Sisa stok di gudang tidak mencukupi untuk jumlah yang dikeluarkan.',
          );
        }
      }

      // 4. Catat transaksi baru ini ke database
      await txn.insert('stock_transactions', transaction.toMap());

      // 5. Update total stok (agregasi) di master produk
      final modifier = transaction.type == TransactionType.inStock ? '+' : '-';
      await txn.rawUpdate(
        'UPDATE products SET current_stock = current_stock $modifier ?, updated_at = ? WHERE id = ?',
        [
          transaction.quantity,
          DateTime.now().toIso8601String(),
          transaction.productId,
        ],
      );
    });
  }

  Future<List<StockTransactionModel>> getActiveBatches(String productId) async {
    final db = await dbService.database;
    final maps = await db.query(
      'stock_transactions',
      where: 'product_id = ? AND type = ? AND remaining_quantity > 0',
      whereArgs: [productId, TransactionType.inStock.name],
      orderBy: 'expiry_date ASC, created_at ASC',
    );
    return maps.map((map) => StockTransactionModel.fromMap(map)).toList();
  }
}
