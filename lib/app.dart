import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockmateapp/routers.dart';
import 'package:stockmateapp/utils/theme/app_theme.dart';
import 'package:stockmateapp/viewmodels/settings_viewmodel.dart';

class StockMateApp extends StatelessWidget {
  const StockMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      title: 'StockMate',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
