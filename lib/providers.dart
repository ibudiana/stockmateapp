import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:stockmateapp/repositories/report_repository.dart';
import 'package:stockmateapp/services/local/dao/report_dao.dart';

import 'package:stockmateapp/services/local/database.dart';
import 'package:stockmateapp/services/local/dao/user_dao.dart';
import 'package:stockmateapp/services/local/dao/product_dao.dart';
import 'package:stockmateapp/services/remote/firebase_auth_service.dart';

import 'package:stockmateapp/repositories/auth_repository.dart';
import 'package:stockmateapp/repositories/product_repository.dart';

import 'package:stockmateapp/viewmodels/auth/auth.dart';
import 'package:stockmateapp/viewmodels/product_viewmodel.dart';
import 'package:stockmateapp/viewmodels/report_viewmodel.dart';

class AppProviders {
  static List<SingleChildWidget> providers() {
    final dbService = DatabaseService();

    return [
      // Database
      Provider<DatabaseService>.value(value: dbService),

      // Firebase Service
      Provider<FirebaseAuthService>(create: (_) => FirebaseAuthService()),

      // --- DAO ---
      Provider<UserDao>(create: (_) => UserDao(dbService: dbService)),
      Provider<ProductDao>(create: (_) => ProductDao(dbService: dbService)),
      Provider<ReportDao>(create: (_) => ReportDao(dbService: dbService)),

      // --- REPOSITORY ---
      Provider<AuthRepositoryImpl>(
        create: (context) => AuthRepositoryImpl(
          firebaseService: context.read<FirebaseAuthService>(),
          userDao: context.read<UserDao>(),
        ),
      ),
      Provider<ProductRepository>(
        create: (context) =>
            ProductRepository(productDao: context.read<ProductDao>()),
      ),
      Provider<ReportRepository>(
        create: (context) =>
            ReportRepository(reportDao: context.read<ReportDao>()),
      ),

      // --- VIEWMODEL ---
      ChangeNotifierProvider<AuthViewModel>(
        create: (context) =>
            AuthViewModel(repository: context.read<AuthRepositoryImpl>()),
      ),
      ChangeNotifierProvider<ProductViewModel>(
        create: (context) =>
            ProductViewModel(repository: context.read<ProductRepository>()),
      ),
      ChangeNotifierProvider<ReportViewModel>(
        create: (context) =>
            ReportViewModel(repository: context.read<ReportRepository>()),
      ),
    ];
  }
}
