import 'package:stockmateapp/models/transaction_detail_model.dart';
import 'package:stockmateapp/services/local/database.dart';

class ReportDao {
  final DatabaseService dbService;

  ReportDao({required this.dbService});

  Future<List<TransactionDetailModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await dbService.database;

    // Pastikan format ISO8601 mencakup awal dan akhir hari dengan tepat
    final startString = startDate.toIso8601String();
    final endString = endDate.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        t.*, 
        p.name AS product_name, 
        p.sku AS product_sku 
      FROM stock_transactions t
      INNER JOIN products p ON t.product_id = p.id
      WHERE t.created_at >= ? AND t.created_at <= ?
      ORDER BY t.created_at DESC
    ''',
      [startString, endString],
    );

    return maps.map((map) => TransactionDetailModel.fromMap(map)).toList();
  }
}
