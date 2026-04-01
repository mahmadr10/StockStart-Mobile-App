// ============================================================
// FILE: lib/utils/app_theme.dart
// PURPOSE: All colors and shared styles in one place
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  static const green        = Color(0xFF22C55E);
  static const greenLight   = Color(0xFFF0FDF4);
  static const greenSoft    = Color(0xFFDCFCE7);
  static const red          = Color(0xFFEF4444);
  static const amber        = Color(0xFFF59E0B);
  static const dark         = Color(0xFF1A1A1A);
  static const grey         = Color(0xFF6B7280);
  static const greyLight    = Color(0xFF9CA3AF);
  static const greyBg       = Color(0xFFF3F4F6);
  static const pageBg       = Color(0xFFF9FAFB);
  static const white        = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    primaryColor: AppColors.green,
    scaffoldBackgroundColor: AppColors.pageBg,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.dark,
      elevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.dark,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}