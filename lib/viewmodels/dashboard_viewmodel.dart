import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stockmateapp/models/stock_transaction_model.dart';
import 'package:stockmateapp/repositories/product_repository.dart';
import 'package:stockmateapp/repositories/report_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final ProductRepository productRepo;
  final ReportRepository reportRepo;

  bool isLoading = true;

  // --- STATISTIK PRODUK ---
  int totalProductTypes = 0;
  double totalStockUnits = 0;
  int lowStockCount = 0;
  int outOfStockCount = 0;

  // --- STATISTIK TRANSAKSI ---
  double todayIn = 0;
  double todayOut = 0;
  int totalTransactions = 0;

  // --- DATA GRAFIK (7 HARI TERAKHIR) ---
  List<FlSpot> trendInSpots = [];
  List<FlSpot> trendOutSpots = [];
  List<String> last7DaysLabels = [];

  DashboardViewModel({required this.productRepo, required this.reportRepo}) {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading = true;
    notifyListeners();

    // 1. Ambil & Hitung Data Produk
    final products = await productRepo.getProducts();
    totalProductTypes = products.length;
    totalStockUnits = 0;
    lowStockCount = 0;
    outOfStockCount = 0;

    for (var p in products) {
      totalStockUnits += p.currentStock;
      if (p.currentStock == 0) {
        outOfStockCount++;
      } else if (p.currentStock <= p.minStock) {
        lowStockCount++;
      }
    }

    // 2. Ambil Transaksi Hari Ini
    final now = DateTime.now();
    final todayReport = await reportRepo.getReport(now, now);

    todayIn = 0;
    todayOut = 0;
    for (var r in todayReport) {
      if (r.transaction.type == TransactionType.inStock) {
        todayIn += r.transaction.quantity;
      } else {
        todayOut += r.transaction.quantity;
      }
    }

    // 3. Ambil Total Semua Transaksi
    final allReport = await reportRepo.getReport(DateTime(2000), now);
    totalTransactions = allReport.length;

    // 4. Kalkulasi Grafik 7 Hari Terakhir
    trendInSpots.clear();
    trendOutSpots.clear();
    last7DaysLabels.clear();

    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    // Loop mundur dari 6 hari yang lalu sampai hari ini (0)
    for (int i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final dailyReport = await reportRepo.getReport(targetDate, targetDate);

      double dIn = 0;
      double dOut = 0;
      for (var r in dailyReport) {
        if (r.transaction.type == TransactionType.inStock) {
          dIn += r.transaction.quantity;
        } else {
          dOut += r.transaction.quantity;
        }
      }

      // X-axis dimulai dari 0 sampai 6
      double xAxis = (6 - i).toDouble();
      trendInSpots.add(FlSpot(xAxis, dIn));
      trendOutSpots.add(FlSpot(xAxis, dOut));

      // Simpan nama hari untuk label sumbu X
      last7DaysLabels.add(days[targetDate.weekday - 1]);
    }

    isLoading = false;
    notifyListeners();
  }
}
