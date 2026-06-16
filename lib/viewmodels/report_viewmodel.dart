import 'package:flutter/material.dart';
import 'package:stockmateapp/models/stock_transaction_model.dart';
import 'package:stockmateapp/models/transaction_detail_model.dart';
import 'package:stockmateapp/repositories/report_repository.dart';

enum ReportTab { today, yesterday, custom }

enum ReportStatus { idle, loading, success, error }

class ReportViewModel extends ChangeNotifier {
  final ReportRepository repository;

  ReportTab _currentTab = ReportTab.today;
  ReportTab get currentTab => _currentTab;

  ReportStatus _status = ReportStatus.idle;
  ReportStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<TransactionDetailModel> _transactions = [];
  List<TransactionDetailModel> get transactions => _transactions;

  // Tanggal kustom
  DateTime _customStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _customEndDate = DateTime.now();
  DateTime get customStartDate => _customStartDate;
  DateTime get customEndDate => _customEndDate;

  // Ringkasan
  double _totalIn = 0;
  double _totalOut = 0;
  double get totalIn => _totalIn;
  double get totalOut => _totalOut;
  double get totalTransaction =>
      _totalIn + _totalOut; // Sesuai logika UI (842 + 442 = 1284)

  ReportViewModel({required this.repository}) {
    fetchReport(); // Ambil data saat inisialisasi
  }

  void setTab(ReportTab tab) {
    if (_currentTab == tab) return;
    _currentTab = tab;
    fetchReport();
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    _customStartDate = start;
    _customEndDate = end;
    if (_currentTab == ReportTab.custom) {
      fetchReport();
    }
  }

  Future<void> fetchReport() async {
    _status = ReportStatus.loading;
    notifyListeners();

    try {
      DateTime start;
      DateTime end;
      final now = DateTime.now();

      switch (_currentTab) {
        case ReportTab.today:
          start = now;
          end = now;
          break;
        case ReportTab.yesterday:
          start = now.subtract(const Duration(days: 1));
          end = now.subtract(const Duration(days: 1));
          break;
        case ReportTab.custom:
          start = _customStartDate;
          end = _customEndDate;
          break;
      }

      _transactions = await repository.getReport(start, end);
      _calculateSummary();

      _status = ReportStatus.success;
    } catch (e) {
      _status = ReportStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void _calculateSummary() {
    _totalIn = 0;
    _totalOut = 0;
    for (var detail in _transactions) {
      if (detail.transaction.type == TransactionType.inStock) {
        _totalIn += detail.transaction.quantity;
      } else {
        _totalOut += detail
            .transaction
            .quantity; // Gunakan absolut untuk kemudahan baca UI
      }
    }
  }
}
