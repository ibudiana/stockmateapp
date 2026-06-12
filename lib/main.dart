import 'package:flutter/material.dart';
import 'utils/theme/app_theme.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Inisialisasi Firebase

  runApp(const StockMateApp());
}

class StockMateApp extends StatelessWidget {
  const StockMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockMate',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('StockMate')));
  }
}
