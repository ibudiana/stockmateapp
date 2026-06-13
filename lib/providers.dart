import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:stockmateapp/services/local/database.dart';
import 'package:stockmateapp/services/local/dao/user_dao.dart';
import 'package:stockmateapp/services/remote/firebase_auth_service.dart';

import 'package:stockmateapp/repositories/auth_repository.dart';

import 'package:stockmateapp/viewmodels/auth/auth.dart';

class AppProviders {
  static List<SingleChildWidget> providers() {
    final dbService = DatabaseService();

    return [
      // Database
      Provider<DatabaseService>.value(value: dbService),

      // Firebase Service
      Provider<FirebaseAuthService>(create: (_) => FirebaseAuthService()),

      // DAO
      Provider<UserDao>(create: (_) => UserDao(dbService: dbService)),

      // Repository
      Provider<AuthRepositoryImpl>(
        create: (context) => AuthRepositoryImpl(
          firebaseService: context.read<FirebaseAuthService>(),
          userDao: context.read<UserDao>(),
        ),
      ),

      // ViewModel
      ChangeNotifierProvider<AuthViewModel>(
        create: (context) =>
            AuthViewModel(repository: context.read<AuthRepositoryImpl>()),
      ),
    ];
  }
}
