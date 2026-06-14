import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stockmateapp/models/product_model.dart';
import 'package:stockmateapp/models/stock_transaction_model.dart';
import 'package:stockmateapp/services/local/dao/product_dao.dart';
import 'package:stockmateapp/services/local/database.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseService dbService;
  late ProductDao dao;

  setUp(() async {
    dbService = DatabaseService(inMemory: true);
    dao = ProductDao(dbService: dbService);
  });

  tearDown(() async {
    final db = await dbService.database;
    await db.close();
  });

  group('ProductDao SQLite Operations', () {
    test('Can Insert and Retrieve Product', () async {
      final product = ProductModel(
        sku: 'BRS-001',
        name: 'Beras Pandan Wangi',
        unit: 'kg',
        minStock: 50,
      );

      await dao.insertProduct(product);
      final products = await dao.getAllProducts();

      expect(products.length, 1);
      expect(products.first.sku, 'BRS-001');
      expect(products.first.currentStock, 0.0);
    });

    test('Can Add Stock Transaction and Update Current Stock', () async {
      final product = ProductModel(
        id: 'prod-1',
        sku: 'GLA-009',
        name: 'Gula Pasir',
        unit: 'kg',
        minStock: 10,
        currentStock: 0,
      );

      await dao.insertProduct(product);

      // Stock In 25kg
      final transactionIn = StockTransactionModel(
        productId: 'prod-1',
        type: TransactionType.inStock,
        quantity: 25,
      );
      await dao.addStockTransaction(transactionIn);

      var updatedProduct = await dao.getProductById('prod-1');
      expect(updatedProduct!.currentStock, 25.0);

      // Stock Out 5kg
      final transactionOut = StockTransactionModel(
        productId: 'prod-1',
        type: TransactionType.outStock,
        quantity: 5,
      );
      await dao.addStockTransaction(transactionOut);

      updatedProduct = await dao.getProductById('prod-1');
      expect(updatedProduct!.currentStock, 20.0);
    });

    test('Handle FEFO/FIFO Logic when Stock Out', () async {
      final product = ProductModel(
        id: 'fefo-prod',
        sku: 'BRS-002',
        name: 'Beras FEFO',
        unit: 'kg',
        minStock: 10,
      );
      await dao.insertProduct(product);

      // Batch 1 Masuk: 20kg (Kedaluwarsa tahun depan)
      await dao.addStockTransaction(
        StockTransactionModel(
          productId: 'fefo-prod',
          type: TransactionType.inStock,
          quantity: 20,
          expiryDate: DateTime(2027, 1, 1),
        ),
      );

      // Batch 2 Masuk: 30kg (Kedaluwarsa bulan depan -> Ini harus keluar duluan!)
      await dao.addStockTransaction(
        StockTransactionModel(
          productId: 'fefo-prod',
          type: TransactionType.inStock,
          quantity: 30,
          expiryDate: DateTime(2026, 7, 1),
        ),
      );

      // Transaksi Keluar: 40kg
      // Harusnya menghabiskan Batch 2 (30kg) lalu memotong Batch 1 (10kg)
      await dao.addStockTransaction(
        StockTransactionModel(
          productId: 'fefo-prod',
          type: TransactionType.outStock,
          quantity: 40,
        ),
      );

      // Assert total stock master
      final p = await dao.getProductById('fefo-prod');
      expect(p!.currentStock, 10.0); // 50 - 40 = 10

      // Assert sisa per batch
      final db = await dbService.database;
      final batches = await db.query(
        'stock_transactions',
        where: 'type = ?',
        whereArgs: ['inStock'],
        orderBy: 'expiry_date ASC',
      );

      // Batch 2 (Exp: Jul 2026) harus habis
      expect(batches[0]['remaining_quantity'], 0.0);
      // Batch 1 (Exp: Jan 2027) harus sisa 10
      expect(batches[1]['remaining_quantity'], 10.0);
    });
  });
}
