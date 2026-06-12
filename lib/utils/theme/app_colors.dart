import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  // Content Colors
  final Color contentPrimary;
  final Color contentSecondary;
  final Color contentTertiary;
  final Color contentPrimaryInverse;
  final Color contentDisabled;
  final Color contentBrand;
  final Color contentLink;
  final Color contentNegative;
  final Color contentPositive;
  final Color contentNotice;
  final Color contentInfo;

  // Background Colors
  final Color backgroundPrimary;
  final Color backgroundHover;
  final Color backgroundPressed;
  final Color backgroundSelected;
  final Color backgroundDisabled;
  final Color backgroundInverse;
  final Color backgroundBrand;
  final Color backgroundNegative;
  final Color backgroundPositive;
  final Color backgroundNotice;
  final Color backgroundInfo;

  // Border Colors
  final Color borderPrimary;
  final Color borderSecondary;
  final Color borderTertiary;
  final Color borderDisabled;
  final Color borderInverse;
  final Color borderBrand;
  final Color borderNegative;
  final Color borderPositive;

  // Surfaces
  final Color surfaceL0;
  final Color surfaceL1;

  const AppColors({
    required this.contentPrimary,
    required this.contentSecondary,
    required this.contentTertiary,
    required this.contentPrimaryInverse,
    required this.contentDisabled,
    required this.contentBrand,
    required this.contentLink,
    required this.contentNegative,
    required this.contentPositive,
    required this.contentNotice,
    required this.contentInfo,
    required this.backgroundPrimary,
    required this.backgroundHover,
    required this.backgroundPressed,
    required this.backgroundSelected,
    required this.backgroundDisabled,
    required this.backgroundInverse,
    required this.backgroundBrand,
    required this.backgroundNegative,
    required this.backgroundPositive,
    required this.backgroundNotice,
    required this.backgroundInfo,
    required this.borderPrimary,
    required this.borderSecondary,
    required this.borderTertiary,
    required this.borderDisabled,
    required this.borderInverse,
    required this.borderBrand,
    required this.borderNegative,
    required this.borderPositive,
    required this.surfaceL0,
    required this.surfaceL1,
  });

  static const AppColors light = AppColors(
    contentPrimary: Color(0xFF323232),
    contentSecondary: Color(0xFF959697),
    contentTertiary: Color(0xFFF8FAFC),
    contentPrimaryInverse: Color(0xFFFEFEFE),
    contentDisabled: Color(0xFFF9FBFD),
    contentBrand: Color(0xFF0F52BA),
    contentLink: Color(0xFF0F52BA),
    contentNegative: Color(0xFFBA1A1A),
    contentPositive: Color(0xFF2DD4BF),
    contentNotice: Color(0xFFFF8F1F),
    contentInfo: Color(0xFF0F52BA),
    backgroundPrimary: Color(0xFFFEFEFE),
    backgroundHover: Color(0xFFFCFDFE),
    backgroundPressed: Color(0xFFFBFCFD),
    backgroundSelected: Color(0xFFCFDCF1),
    backgroundDisabled: Color(0xFFFCFDFE),
    backgroundInverse: Color(0xFF323232),
    backgroundBrand: Color(0xFF0F52BA),
    backgroundNegative: Color(0xFFBA1A1A),
    backgroundPositive: Color(0xFF2DD4BF),
    backgroundNotice: Color(0xFFFF8F1F),
    backgroundInfo: Color(0xFF0F52BA),
    borderPrimary: Color(0xFFC6C8CA),
    borderSecondary: Color(0xFFF9FBFD),
    borderTertiary: Color(0xFFFBFCFD),
    borderDisabled: Color(0xFFFCFDFE),
    borderInverse: Color(0xFFFEFEFE),
    borderBrand: Color(0xFF0F52BA),
    borderNegative: Color(0xFFBA1A1A),
    borderPositive: Color(0xFF2DD4BF),
    surfaceL0: Color(0xFFFEFEFE),
    surfaceL1: Color(0xFFFEFEFE),
  );

  static const AppColors dark = AppColors(
    contentPrimary: Color(0xFFFEFEFE),
    contentSecondary: Color(0xFFFBFCFD),
    contentTertiary: Color(0xFFF8FAFC),
    contentPrimaryInverse: Color(0xFF323232),
    contentDisabled: Color(0xFFC6C8CA),
    contentBrand: Color(0xFF3F75C8),
    contentLink: Color(0xFF3F75C8),
    contentNegative: Color(0xFFC84848),
    contentPositive: Color(0xFF57DDCC),
    contentNotice: Color(0xFFFFA54C),
    contentInfo: Color(0xFF3F75C8),
    backgroundPrimary: Color(0xFF323232),
    backgroundHover: Color(0xFF636465),
    backgroundPressed: Color(0xFF959697),
    backgroundSelected: Color(0xFF031025),
    backgroundDisabled: Color(0xFF636465),
    backgroundInverse: Color(0xFFFEFEFE),
    backgroundBrand: Color(0xFF3F75C8),
    backgroundNegative: Color(0xFFC84848),
    backgroundPositive: Color(0xFF57DDCC),
    backgroundNotice: Color(0xFFFFA54C),
    backgroundInfo: Color(0xFF3F75C8),
    borderPrimary: Color(0xFFF9FBFD),
    borderSecondary: Color(0xFFC6C8CA),
    borderTertiary: Color(0xFF959697),
    borderDisabled: Color(0xFF636465),
    borderInverse: Color(0xFF323232),
    borderBrand: Color(0xFF3F75C8),
    borderNegative: Color(0xFFC84848),
    borderPositive: Color(0xFF57DDCC),
    surfaceL0: Color(0xFF323232),
    surfaceL1: Color(0xFF636465),
  );

  @override
  AppColors copyWith({
    Color? contentPrimary,
    Color? contentSecondary,
    Color? contentTertiary,
    Color? contentPrimaryInverse,
    Color? contentDisabled,
    Color? contentBrand,
    Color? contentLink,
    Color? contentNegative,
    Color? contentPositive,
    Color? contentNotice,
    Color? contentInfo,
    Color? backgroundPrimary,
    Color? backgroundHover,
    Color? backgroundPressed,
    Color? backgroundSelected,
    Color? backgroundDisabled,
    Color? backgroundInverse,
    Color? backgroundBrand,
    Color? backgroundNegative,
    Color? backgroundPositive,
    Color? backgroundNotice,
    Color? backgroundInfo,
    Color? borderPrimary,
    Color? borderSecondary,
    Color? borderTertiary,
    Color? borderDisabled,
    Color? borderInverse,
    Color? borderBrand,
    Color? borderNegative,
    Color? borderPositive,
    Color? surfaceL0,
    Color? surfaceL1,
  }) {
    return AppColors(
      contentPrimary: contentPrimary ?? this.contentPrimary,
      contentSecondary: contentSecondary ?? this.contentSecondary,
      contentTertiary: contentTertiary ?? this.contentTertiary,
      contentPrimaryInverse:
          contentPrimaryInverse ?? this.contentPrimaryInverse,
      contentDisabled: contentDisabled ?? this.contentDisabled,
      contentBrand: contentBrand ?? this.contentBrand,
      contentLink: contentLink ?? this.contentLink,
      contentNegative: contentNegative ?? this.contentNegative,
      contentPositive: contentPositive ?? this.contentPositive,
      contentNotice: contentNotice ?? this.contentNotice,
      contentInfo: contentInfo ?? this.contentInfo,
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundHover: backgroundHover ?? this.backgroundHover,
      backgroundPressed: backgroundPressed ?? this.backgroundPressed,
      backgroundSelected: backgroundSelected ?? this.backgroundSelected,
      backgroundDisabled: backgroundDisabled ?? this.backgroundDisabled,
      backgroundInverse: backgroundInverse ?? this.backgroundInverse,
      backgroundBrand: backgroundBrand ?? this.backgroundBrand,
      backgroundNegative: backgroundNegative ?? this.backgroundNegative,
      backgroundPositive: backgroundPositive ?? this.backgroundPositive,
      backgroundNotice: backgroundNotice ?? this.backgroundNotice,
      backgroundInfo: backgroundInfo ?? this.backgroundInfo,
      borderPrimary: borderPrimary ?? this.borderPrimary,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      borderTertiary: borderTertiary ?? this.borderTertiary,
      borderDisabled: borderDisabled ?? this.borderDisabled,
      borderInverse: borderInverse ?? this.borderInverse,
      borderBrand: borderBrand ?? this.borderBrand,
      borderNegative: borderNegative ?? this.borderNegative,
      borderPositive: borderPositive ?? this.borderPositive,
      surfaceL0: surfaceL0 ?? this.surfaceL0,
      surfaceL1: surfaceL1 ?? this.surfaceL1,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      contentPrimary: Color.lerp(contentPrimary, other.contentPrimary, t)!,
      // Ulangi lerp untuk semua properti di atas
      contentSecondary: Color.lerp(
        contentSecondary,
        other.contentSecondary,
        t,
      )!,
      contentTertiary: Color.lerp(contentTertiary, other.contentTertiary, t)!,
      contentPrimaryInverse: Color.lerp(
        contentPrimaryInverse,
        other.contentPrimaryInverse,
        t,
      )!,
      contentDisabled: Color.lerp(contentDisabled, other.contentDisabled, t)!,
      contentBrand: Color.lerp(contentBrand, other.contentBrand, t)!,
      contentLink: Color.lerp(contentLink, other.contentLink, t)!,
      contentNegative: Color.lerp(contentNegative, other.contentNegative, t)!,
      contentPositive: Color.lerp(contentPositive, other.contentPositive, t)!,
      contentNotice: Color.lerp(contentNotice, other.contentNotice, t)!,
      contentInfo: Color.lerp(contentInfo, other.contentInfo, t)!,
      backgroundPrimary: Color.lerp(
        backgroundPrimary,
        other.backgroundPrimary,
        t,
      )!,
      backgroundHover: Color.lerp(backgroundHover, other.backgroundHover, t)!,
      backgroundPressed: Color.lerp(
        backgroundPressed,
        other.backgroundPressed,
        t,
      )!,
      backgroundSelected: Color.lerp(
        backgroundSelected,
        other.backgroundSelected,
        t,
      )!,
      backgroundDisabled: Color.lerp(
        backgroundDisabled,
        other.backgroundDisabled,
        t,
      )!,
      backgroundInverse: Color.lerp(
        backgroundInverse,
        other.backgroundInverse,
        t,
      )!,
      backgroundBrand: Color.lerp(backgroundBrand, other.backgroundBrand, t)!,
      backgroundNegative: Color.lerp(
        backgroundNegative,
        other.backgroundNegative,
        t,
      )!,
      backgroundPositive: Color.lerp(
        backgroundPositive,
        other.backgroundPositive,
        t,
      )!,
      backgroundNotice: Color.lerp(
        backgroundNotice,
        other.backgroundNotice,
        t,
      )!,
      backgroundInfo: Color.lerp(backgroundInfo, other.backgroundInfo, t)!,
      borderPrimary: Color.lerp(borderPrimary, other.borderPrimary, t)!,
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t)!,
      borderTertiary: Color.lerp(borderTertiary, other.borderTertiary, t)!,
      borderDisabled: Color.lerp(borderDisabled, other.borderDisabled, t)!,
      borderInverse: Color.lerp(borderInverse, other.borderInverse, t)!,
      borderBrand: Color.lerp(borderBrand, other.borderBrand, t)!,
      borderNegative: Color.lerp(borderNegative, other.borderNegative, t)!,
      borderPositive: Color.lerp(borderPositive, other.borderPositive, t)!,
      surfaceL0: Color.lerp(surfaceL0, other.surfaceL0, t)!,
      surfaceL1: Color.lerp(surfaceL1, other.surfaceL1, t)!,
    );
  }
}
