import 'package:stockmateapp/models/transaction_detail_model.dart';
import 'package:stockmateapp/services/local/dao/report_dao.dart';

class ReportRepository {
  final ReportDao reportDao;

  ReportRepository({required this.reportDao});

  Future<List<TransactionDetailModel>> getReport(
    DateTime start,
    DateTime end,
  ) async {
    // Normalisasi: start = 00:00:00, end = 23:59:59
    final startOfDay = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return await reportDao.getTransactionsByDateRange(startOfDay, endOfDay);
  }
}
