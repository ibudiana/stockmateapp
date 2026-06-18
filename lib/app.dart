import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stockmateapp/routers.dart';
import 'package:stockmateapp/utils/theme/app_theme.dart';
import 'package:stockmateapp/viewmodels/settings_viewmodel.dart';

class StockMateApp extends StatefulWidget {
  const StockMateApp({super.key});

  @override
  State<StockMateApp> createState() => _StockMateAppState();
}

class _StockMateAppState extends State<StockMateApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = AppRouter.createRouter(context);
  }

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
