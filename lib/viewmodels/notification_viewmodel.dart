import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockmateapp/models/stock_transaction_model.dart';
import 'package:stockmateapp/repositories/product_repository.dart';
import 'package:stockmateapp/repositories/report_repository.dart';
import 'package:stockmateapp/viewmodels/settings_viewmodel.dart';

// Model khusus untuk menampung data UI Notifikasi
class AppNotification {
  final String title;
  final String message;
  final DateTime time;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isUrgent;
  final String? sku;
  final String? extraText;

  AppNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isUrgent = false,
    this.sku,
    this.extraText,
  });
}

class NotificationViewModel extends ChangeNotifier {
  final ProductRepository productRepo;
  final ReportRepository reportRepo;
  final SettingsViewModel settings;

  int unreadCount = 0;
  bool isLoading = true;

  List<AppNotification> recentNotifications = [];
  List<AppNotification> olderNotifications = [];

  NotificationViewModel({
    required this.productRepo,
    required this.reportRepo,
    required this.settings,
  }) {
    // Dengarkan perubahan setting
    settings.addListener(generateNotifications);

    // Generate saat pertama kali ViewModel dibuat
    Future.delayed(Duration.zero, () {
      generateNotifications();
    });
  }

  Future<void> generateNotifications() async {
    isLoading = true;
    notifyListeners();

    List<AppNotification> generatedRecent = [];
    List<AppNotification> generatedOlder = [];
    final now = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    final lastReadString = prefs.getString('lastReadTime');
    final lastReadTime = lastReadString != null
        ? DateTime.parse(lastReadString)
        : null;

    // Fungsi bantuan untuk memilah notif masuk ke Terbaru (Hari ini) atau Minggu Ini
    void addNotification(AppNotification notif) {
      final isToday =
          notif.time.day == now.day &&
          notif.time.month == now.month &&
          notif.time.year == now.year;
      if (isToday) {
        generatedRecent.add(notif);
      } else {
        generatedOlder.add(notif);
      }
    }

    // 1. CEK STATUS PRODUK (Menipis, Habis, Kedaluwarsa)
    final products = await productRepo.getProducts();
    for (var p in products) {
      // Peringatan Stok Habis
      if (settings.notifyOutOfStock && p.currentStock == 0) {
        addNotification(
          AppNotification(
            title: 'Stok Habis: ${p.name}',
            message:
                'Notifikasi instan: Produk ini sudah tidak tersedia di inventaris.',
            time: p
                .updatedAt, // BUKAN now, melainkan waktu produk terakhir terupdate
            isUrgent: true,
            icon: Icons.error_outline,
            iconBgColor: Colors.redAccent.withOpacity(0.2),
            iconColor: Colors.red[700]!,
            sku: p.sku,
            extraText: 'Sisa: 0 ${p.unit}',
          ),
        );
      }
      // Peringatan Stok Menipis
      else if (settings.notifyLowStock && p.currentStock <= p.minStock) {
        addNotification(
          AppNotification(
            title: 'Stok Menipis: ${p.name}',
            message: 'Peringatan stok kritis terdeteksi pada gudang utama.',
            time: p.updatedAt, // Menggunakan waktu produk terupdate
            isUrgent: true,
            icon: Icons.warning_amber_rounded,
            iconBgColor: Colors.orangeAccent.withOpacity(0.2),
            iconColor: Colors.orange[800]!,
            sku: p.sku,
            extraText: 'Sisa: ${p.currentStock.toStringAsFixed(0)} ${p.unit}',
          ),
        );
      }

      // Peringatan Kedaluwarsa (< 30 Hari)
      if (settings.notifyExpiry) {
        final batches = await productRepo.getActiveBatches(p.id);
        for (var b in batches) {
          if (b.expiryDate != null &&
              b.expiryDate!.difference(now).inDays <= 30) {
            addNotification(
              AppNotification(
                title: 'Hampir Kedaluwarsa: ${p.name}',
                message:
                    'Batch dengan sisa ${b.remainingQuantity} ${p.unit} akan kedaluwarsa kurang dari 30 hari.',
                // Untuk expired, kita biarkan memakai waktu produk di-update juga
                time: p.updatedAt,
                icon: Icons.timer_outlined,
                iconBgColor: Colors.purpleAccent.withOpacity(0.2),
                iconColor: Colors.purple[700]!,
              ),
            );
          }
        }
      }
    }

    // 2. CEK AKTIVITAS GUDANG (Transaksi In/Out 7 Hari Terakhir)
    if (settings.notifyActivity) {
      final transactions = await reportRepo.getReport(
        now.subtract(const Duration(days: 7)),
        now,
      );
      for (var r in transactions) {
        final isMasuk = r.transaction.type == TransactionType.inStock;

        addNotification(
          AppNotification(
            title: 'Stok ${isMasuk ? 'Masuk' : 'Keluar'}: ${r.productName}',
            message:
                '${r.transaction.quantity.toStringAsFixed(0)} unit telah ${isMasuk ? 'ditambahkan ke' : 'dikeluarkan dari'} inventaris.',
            time: r.transaction.createdAt, // Waktu asli transaksi
            icon: isMasuk
                ? Icons.add_circle_outline
                : Icons.remove_circle_outline,
            iconBgColor: isMasuk
                ? Colors.tealAccent.withOpacity(0.4)
                : Colors.grey[300]!,
            iconColor: isMasuk ? Colors.teal[800]! : Colors.grey[800]!,
          ),
        );
      }
    }

    // Urutkan dari yang paling baru ke yang paling lama
    generatedRecent.sort((a, b) => b.time.compareTo(a.time));
    generatedOlder.sort((a, b) => b.time.compareTo(a.time));

    // Hitung Notifikasi Belum Dibaca HANYA dari yang Terbaru
    unreadCount = 0;
    for (var notif in generatedRecent) {
      if (lastReadTime == null || notif.time.isAfter(lastReadTime)) {
        unreadCount++;
      }
    }

    recentNotifications = generatedRecent;
    olderNotifications = generatedOlder;
    isLoading = false;
    notifyListeners();
  }

  // Fungsi yang dipanggil saat icon lonceng diklik di Dashboard
  Future<void> clearNotificationBadge() async {
    final prefs = await SharedPreferences.getInstance();

    // Simpan waktu SAAT INI sebagai waktu terakhir notifikasi dibaca
    await prefs.setString('lastReadTime', DateTime.now().toIso8601String());

    unreadCount = 0;
    notifyListeners();
  }
}
