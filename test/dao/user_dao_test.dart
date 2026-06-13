import 'package:flutter_test/flutter_test.dart';
import 'package:stockmateapp/models/user_model.dart';
import 'package:stockmateapp/services/local/dao/user_dao.dart';
import 'package:stockmateapp/services/local/database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseService dbService;
  late UserDao dao;

  setUp(() {
    dbService = DatabaseService(inMemory: true);
    // Inisialisasi dao dipindah ke sini agar bisa dipakai di semua test
    dao = UserDao(dbService: dbService);
  });

  tearDown(() async {
    final db = await dbService.database;
    await db.close();
  });

  group('UserDao SQLite Operations', () {
    // --- 1. TEST REGISTER (INSERT) ---
    test('Can Insert User ke SQLite', () async {
      // Arrange
      final user = UserModel(
        id: '12345',
        name: 'Wayan Budiana',
        username: 'ibudiana',
        password: 'password123',
        email: 'budi@gmail.com',
        role: UserRole.admin,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await dao.insertUser(user);

      // Assert
      final result = await dao.getUserById('12345');
      expect(result, isNotNull);
      expect(result!.email, 'budi@gmail.com');
      expect(result.name, 'Wayan Budiana');
      expect(result.username, 'ibudiana');
      expect(result.role, UserRole.admin);
      expect(result.createdAt, isNotNull);
      expect(result.updatedAt, isNotNull);
    });

    // --- 2. TEST LOGIN (GET BY EMAIL) - SUKSES ---
    test('Can get user by email untuk keperluan Login (Skenario Sukses)', () async {
      // Arrange: Kita harus punya data user di database terlebih dahulu
      final user = UserModel(
        id: '123456',
        name: 'Wayan Budiana',
        username: 'admin_toko',
        password: 'password_rahasia',
        email: 'admin@stockmate.com',
        role: UserRole.admin,
      );
      await dao.insertUser(user);

      // Act: Simulasi saat ViewModel mencoba mengambil data berdasarkan email inputan user
      final result = await dao.getUserByEmail('admin@stockmate.com');

      // Assert: Pastikan data ditemukan dan passwordnya cocok untuk dicek nanti
      expect(result, isNotNull);
      expect(result!.email, 'admin@stockmate.com');
      expect(result.password, 'password_rahasia');
    });

    // --- 3. TEST LOGIN (GET BY EMAIL) - GAGAL ---
    test(
      'Return null jika email tidak terdaftar saat Login (Skenario Gagal)',
      () async {
        // Act: Langsung mencoba mencari email tanpa ada data di database (atau email salah)
        final result = await dao.getUserByEmail('email_tidak_ada@gmail.com');

        // Assert: Pastikan SQLite mengembalikan null, sehingga Repository bisa melempar pesan Error
        expect(result, isNull);
      },
    );

    // --- 4. TEST LOGIN (Email and Password) - GAGAL ---
    test(
      'Return null jika email tidak terdaftar saat Login (Skenario Gagal)',
      () async {
        // Arrange: Masukkan data user ke database terlebih dahulu
        final user = UserModel(
          id: '123457',
          name: 'Siti Aminah',
          username: 'admin_siti',
          password: 'siti_password',
          email: 'siti@stockmate.com',
          role: UserRole.admin,
        );
        await dao.insertUser(user);

        // Act: Simulasi saat ViewModel mencoba mengambil data berdasarkan email inputan user
        final result = await dao.getUserByEmail('siti@stockmate.com');
        final isPasswordValid = result!.password == 'salah_password';

        // Assert: Pastikan data ditemukan tapi passwordnya salah, sehingga Repository bisa melempar pesan Error
        expect(result, isNotNull);
        expect(result!.email, 'siti@stockmate.com');
        expect(isPasswordValid, isFalse);
      },
    );

    // --- 5. TEST LOGIN (Email and Password) - BERHASIL ---
    test(
      'Return UserModel jika email ditemukan saat Login (Skenario Berhasil)',
      () async {
        // Arrange: Masukkan data user ke database terlebih dahulu
        final user = UserModel(
          id: '123456',
          name: 'Siti Aminah',
          username: 'admin_siti',
          password: 'siti_password',
          email: 'siti@stockmate.com',
          role: UserRole.admin,
        );
        await dao.insertUser(user);

        // Act: Simulasi saat ViewModel mencoba mengambil data berdasarkan email inputan user
        final result = await dao.getUserByEmail('siti@stockmate.com');

        // Assert: Pastikan data ditemukan dan passwordnya cocok untuk dicek nanti
        expect(result, isNotNull);
        expect(result!.email, 'siti@stockmate.com');
        expect(result.password, 'siti_password');
      },
    );
  });
}
