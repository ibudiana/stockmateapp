import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'Roboto'; // Atau 'Inter' / 'SF Pro Text'

  // --- Text Styles ---
  static const TextStyle textXSRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400, // Regular
    height: 14 / 10,
    letterSpacing: 0,
  );

  static const TextStyle textXSSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600, // SemiBold
    height: 14 / 10,
    letterSpacing: 0,
  );

  static const TextStyle textSRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0,
  );

  static const TextStyle textSSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0,
  );

  static const TextStyle textMRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: 0,
  );

  static const TextStyle textMSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0,
  );

  static const TextStyle textLRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: 0,
  );

  static const TextStyle textLSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    letterSpacing: 0,
  );

  static const TextStyle textXLRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 28 / 20,
    letterSpacing: 0,
  );

  static const TextStyle textXLSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: 0,
  );

  // --- Headings (Semibold by default based on token) ---
  static const TextStyle heading2XS = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 16 / 14,
    letterSpacing: 0,
  );

  static const TextStyle headingXS = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    letterSpacing: -0.5,
  );

  static const TextStyle headingS = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.5,
  );

  static const TextStyle headingM = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    letterSpacing: -0.5,
  );

  static const TextStyle headingL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    letterSpacing: -1,
  );

  static const TextStyle headingXL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 40 / 32,
    letterSpacing: -1,
  );

  static const TextStyle heading2XL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 48 / 40,
    letterSpacing: -1,
  );

  static const TextStyle heading3XL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w600,
    height: 56 / 48,
    letterSpacing: -1,
  );

  static const TextStyle heading4XL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 56,
    fontWeight: FontWeight.w600,
    height: 64 / 56,
    letterSpacing: -1,
  );

  static const TextStyle heading5XL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 64,
    fontWeight: FontWeight.w600,
    height: 72 / 64,
    letterSpacing: -1,
  );
}
