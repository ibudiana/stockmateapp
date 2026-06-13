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
}
