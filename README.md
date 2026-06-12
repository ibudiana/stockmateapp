# StockMateApp

StockMate adalah aplikasi manajemen inventaris _standalone mobile offline_ yang dirancang khusus untuk pemilik UMKM dan toko kelontong harian. Aplikasi ini mempermudah pencatatan stok, mencegah kerugian akibat barang kedaluwarsa melalui algoritma FIFO (_First-In-First-Out_) otomatis, dan mempercepat transaksi operasional menggunakan pemindai _barcode_.

## ✨ Fitur Utama

- **100% Offline-First:** Beroperasi penuh tanpa ketergantungan koneksi internet (data inventaris disimpan di penyimpanan lokal SQLite perangkat).
- **Autentikasi Hybrid:** Menggunakan Firebase untuk keamanan login dan pemulihan kata sandi via OTP, sementara operasional inti tetap luring.
- **Mesin FIFO Otomatis:** Pemotongan stok keluar diprioritaskan secara otomatis pada _batch_ barang yang memiliki tanggal kedaluwarsa paling dekat.
- **Barcode Scanner:** Integrasi kamera perangkat untuk identifikasi produk secara instan tanpa perlu mengetik SKU manual.
- **Sistem Peringatan Dini:** Indikator visual warna dan _red badge notification_ untuk memantau barang yang mendekati masa kritis kedaluwarsa.
- **Pencadangan Lokal (Backup):** Fitur ekspor dan impor _database_ `.db` langsung ke memori internal ponsel cerdas untuk keamanan data mandiri.

## 🛠️ Tech Stack & Arsitektur

- **Framework:** [Flutter](https://flutter.dev/)
- **Database Lokal:** [sqflite](https://pub.dev/packages/sqflite)
- **Autentikasi:** [Firebase Auth](https://firebase.google.com/docs/auth)
- **State Management:** Provider
- **Scanner Hardware:** [mobile_scanner](https://pub.dev/packages/mobile_scanner)
- **Arsitektur:** **MVVM** (_Model-View-ViewModel_) yang dikombinasikan dengan **Repository Pattern** untuk menjembatani sumber data (_Local SQLite_ & _Remote Firebase_).

## 📂 Struktur Direktori Utama

```text
lib/
├── models/         # Representasi entitas tabel (User, Product, StockBatch, Transaction)
├── services/       # Driver database lokal (SQLiteHelper) & cloud (FirebaseService)
├── repositories/   # Abstraksi logika yang menentukan sumber data mana yang dipanggil
├── viewmodels/     # State management dan logika bisnis utama (Auth, Inventory, Dashboard)
├── views/          # Lapisan antarmuka pengguna (Screens & Widgets)
└── utils/          # Konstanta tema, warna indikator FIFO, dan format tanggal
```
