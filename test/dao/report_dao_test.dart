import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stockmateapp/models/product_model.dart';
import 'package:stockmateapp/models/stock_transaction_model.dart';
import 'package:stockmateapp/services/local/dao/product_dao.dart';
import 'package:stockmateapp/services/local/dao/report_dao.dart';
import 'package:stockmateapp/services/local/database.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseService dbService;
  late ProductDao productDao;
  late ReportDao reportDao;

  setUp(() async {
    dbService = DatabaseService(inMemory: true);
    productDao = ProductDao(dbService: dbService);
    reportDao = ReportDao(dbService: dbService);
  });

  tearDown(() async {
    final db = await dbService.database;
    await db.close();
  });

  group('ReportDao SQL JOIN Tests', () {
    test(
      'getTransactionsByDateRange mengambil data gabungan dengan benar',
      () async {
        // 1. Setup Data Induk (Produk)
        final product = ProductModel(
          id: 'prod-report',
          sku: 'RPT-001',
          name: 'Kopi Hitam Premium',
          unit: 'kg',
          minStock: 10,
        );
        await productDao.insertProduct(product);

        // 2. Setup Data Transaksi (Hari ini dan Kemarin)
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));

        // Transaksi Hari Ini (Masuk 50)
        await productDao.addStockTransaction(
          StockTransactionModel(
            productId: 'prod-report',
            type: TransactionType.inStock,
            quantity: 50,
            createdAt: today,
          ),
        );

        // Transaksi Kemarin (Keluar 5)
        await productDao.addStockTransaction(
          StockTransactionModel(
            productId: 'prod-report',
            type: TransactionType.outStock,
            quantity: 5,
            createdAt: yesterday,
          ),
        );

        // 3. Act: Ambil laporan KHUSUS HARI INI
        final startOfDay = DateTime(
          today.year,
          today.month,
          today.day,
          0,
          0,
          0,
        );
        final endOfDay = DateTime(
          today.year,
          today.month,
          today.day,
          23,
          59,
          59,
        );

        final results = await reportDao.getTransactionsByDateRange(
          startOfDay,
          endOfDay,
        );

        // 4. Assert: Harus hanya dapat 1 transaksi (Hari Ini) dengan data gabungan
        expect(results.length, 1);
        expect(
          results.first.productName,
          'Kopi Hitam Premium',
        ); // Hasil JOIN bekerja
        expect(results.first.productSku, 'RPT-001');
        expect(results.first.transaction.quantity, 50.0);
        expect(results.first.transaction.type, TransactionType.inStock);
      },
    );
  });
}
