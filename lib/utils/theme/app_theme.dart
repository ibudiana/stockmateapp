import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.light.backgroundPrimary,
      extensions: const <ThemeExtension<dynamic>>[AppColors.light],
      // Anda bisa memetakan warna brand ke ColorScheme standar jika diperlukan
      colorScheme: ColorScheme.light(
        primary: AppColors.light.backgroundBrand,
        error: AppColors.light.backgroundNegative,
        surface: AppColors.light.backgroundPrimary,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.dark.backgroundPrimary,
      extensions: const <ThemeExtension<dynamic>>[AppColors.dark],
      colorScheme: ColorScheme.dark(
        primary: AppColors.dark.backgroundBrand,
        error: AppColors.dark.backgroundNegative,
        surface: AppColors.dark.backgroundPrimary,
      ),
    );
  }
}
