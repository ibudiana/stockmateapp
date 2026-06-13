import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:stockmateapp/firebase_options.dart';
import 'package:stockmateapp/repositories/auth_repository.dart';
import 'package:stockmateapp/services/local/database.dart';
import 'package:stockmateapp/services/local/dao/user_dao.dart';
import 'package:stockmateapp/services/remote/firebase_auth_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  late AuthRepositoryImpl repository;
  late DatabaseService dbService;
  late UserDao userDao;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  setUp(() {
    dbService = DatabaseService(inMemory: true);
    userDao = UserDao(dbService: dbService);

    repository = AuthRepositoryImpl(
      firebaseService: FirebaseAuthService(),
      userDao: userDao,
    );
  });

  testWidgets('Register user using Firebase Auth', (tester) async {
    final email = 'repo_${DateTime.now().millisecondsSinceEpoch}@gmail.com';

    final user = await repository.registerAndSync(
      'Test User',
      'testuser',
      email,
      'password123',
    );

    expect(user.id, isNotEmpty);
    expect(user.email, email);

    final localUser = await userDao.getUserById(user.id);

    expect(localUser, isNotNull);
    expect(localUser!.email, email);
  });

  testWidgets('Send password reset email via Firebase Auth', (tester) async {
    final email = 'reset_${DateTime.now().millisecondsSinceEpoch}@gmail.com';

    // 1. Arrange: Buat akun terlebih dahulu
    await repository.registerAndSync(
      'Wayan Budiana',
      'wayan_reset',
      email,
      'password123',
    );

    // 2. Act & Assert: Fungsi tidak boleh melempar error (returnsNormally)
    await expectLater(repository.resetPassword(email), completes);
  });

  testWidgets('Hybrid Login resyncs SQLite when password differs', (
    tester,
  ) async {
    final email = 'hybrid_${DateTime.now().millisecondsSinceEpoch}@gmail.com';
    final actualFirebasePassword = 'password_asli_123';

    // 1. Arrange: Register user ke Firebase dan SQLite
    await repository.registerAndSync(
      'Wayan Budiana',
      'wayan_hybrid',
      email,
      actualFirebasePassword,
    );

    // 2. Simulasikan Desync: User melakukan reset password via Firebase (misal lupa password), sehingga password di Firebase berubah, tapi SQLite belum diperbarui.
    await userDao.updatePassword(email, 'sandi_lama_usang');

    // Pastikan SQLite benar-benar menyimpan password lama
    var localUser = await userDao.getUserByEmail(email);
    expect(localUser!.password, 'sandi_lama_usang');

    // 3. Act: User mencoba login menggunakan password yang benar di Firebase
    final loggedInUser = await repository.login(email, actualFirebasePassword);

    // 4. Assert: Login harus berhasil
    expect(loggedInUser.email, email);
    expect(loggedInUser.password, actualFirebasePassword);

    // 5. Assert: SQLite LOKAL harus otomatis diperbarui ke password baru
    localUser = await userDao.getUserByEmail(email);
    expect(localUser!.password, actualFirebasePassword);
  });
}
