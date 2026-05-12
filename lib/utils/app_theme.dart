// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // ── Dark palette ──
  static const Color primary       = Color(0xFF00E5A0);
  static const Color danger        = Color(0xFFFF4D6A);
  static const Color background    = Color(0xFF080B10);
  static const Color surface       = Color(0xFF0F1520);
  static const Color surface2      = Color(0xFF16202E);
  static const Color border        = Color(0xFF1E2D3D);
  static const Color textPrimary   = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF6B7E92);
  static const Color warning       = Color(0xFFFFB020);
  static const Color info          = Color(0xFF4DA8FF);
  static const Color accent        = Color(0xFF7C5CFF);

  // ── Light palette ──
  static const Color lBackground    = Color(0xFFF5F7FA);
  static const Color lSurface       = Color(0xFFFFFFFF);
  static const Color lSurface2      = Color(0xFFEFF2F6);
  static const Color lBorder        = Color(0xFFDDE3EC);
  static const Color lTextPrimary   = Color(0xFF0D1117);
  static const Color lTextSecondary = Color(0xFF6B7A90);

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    scaffoldBg: background,
    surfaceColor: surface,
    textPrimaryColor: textPrimary,
    textSecondaryColor: textSecondary,
    borderColor: border,
    inputFill: surface,
  );

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    scaffoldBg: lBackground,
    surfaceColor: lSurface,
    textPrimaryColor: lTextPrimary,
    textSecondaryColor: lTextSecondary,
    borderColor: lBorder,
    inputFill: lSurface,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffoldBg,
    required Color surfaceColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required Color borderColor,
    required Color inputFill,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.black,
        secondary: accent,
        onSecondary: Colors.white,
        error: danger,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimaryColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: textSecondaryColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor),
          foregroundColor: textPrimaryColor,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondaryColor,
        indicatorColor: primary,
        dividerColor: borderColor,
      ),
      dividerColor: borderColor,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primary,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surface2 : lSurface2,
        contentTextStyle: TextStyle(color: textPrimaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected) ? primary : null),
        trackColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected) ? primary.withOpacity(0.4) : null),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
            color: textPrimaryColor, fontSize: 18, fontWeight: FontWeight.w700),
        contentTextStyle: TextStyle(color: textSecondaryColor, fontSize: 14),
      ),
    );
  }

  static Color riskColor(String risk) {
    switch (risk) {
      case 'Low':    return primary;
      case 'Medium': return warning;
      case 'High':   return danger;
      default:       return textSecondary;
    }
  }

  static Color changeColor(double change) => change >= 0 ? primary : danger;

  static String formatMarketCap(double? cap) {
    if (cap == null) return 'N/A';
    if (cap >= 1e12) return '\$${(cap / 1e12).toStringAsFixed(2)}T';
    if (cap >= 1e9)  return '\$${(cap / 1e9).toStringAsFixed(2)}B';
    if (cap >= 1e6)  return '\$${(cap / 1e6).toStringAsFixed(2)}M';
    return '\$${cap.toStringAsFixed(0)}';
  }
}

class AppColors {
  static const Color green     = AppTheme.primary;
  static const Color red       = AppTheme.danger;
  static const Color dark      = AppTheme.textPrimary;
  static const Color grey      = AppTheme.textSecondary;
  static const Color greyLight = Color(0xFF3D5068);
  static const Color greyBg    = AppTheme.surface;
  static const Color white     = AppTheme.surface2;
  static const Color pageBg    = AppTheme.background;
  static const Color amber     = AppTheme.warning;
}

const List<Map<String, String>> kPopularTickers = [
  {'ticker': 'AAPL',    'name': 'Apple Inc.'},
  {'ticker': 'NVDA',    'name': 'NVIDIA Corp.'},
  {'ticker': 'MSFT',    'name': 'Microsoft Corp.'},
  {'ticker': 'TSLA',    'name': 'Tesla Inc.'},
  {'ticker': 'AMZN',    'name': 'Amazon.com'},
  {'ticker': 'GOOGL',   'name': 'Alphabet Inc.'},
  {'ticker': 'META',    'name': 'Meta Platforms'},
  {'ticker': 'BRK-B',   'name': 'Berkshire Hathaway'},
  {'ticker': 'COIN',    'name': 'Coinbase Global'},
  {'ticker': 'PLTR',    'name': 'Palantir Tech.'},
];