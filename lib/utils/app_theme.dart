// ============================================================
// FILE: lib/utils/app_theme.dart
// ============================================================

import 'package:flutter/material.dart';

class AppTheme {
  // ── Palette (mirrors Streamlit dark finance theme) ──
  static const Color primary = Color(0xFF00CC96);      // Mint Green
  static const Color danger = Color(0xFFEF553B);       // Red
  static const Color background = Color(0xFF0E1117);   // Deep dark
  static const Color surface = Color(0xFF161B22);      // Card surface
  static const Color border = Color(0xFF30363D);       // Borders
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color warning = Color(0xFFFFA500);
  static const Color info = Color(0xFF58A6FF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,

      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        onSurface: textPrimary,
        error: danger,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 1),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary),
        ),
        hintStyle: const TextStyle(color: textSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withOpacity(0.2),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ✅ FIXED: TabBarTheme → TabBarThemeData
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
        dividerColor: border,
      ),

      dividerColor: border,
      fontFamily: 'SF Pro Display',
    );
  }

  // ── Helpers ──
  static Color riskColor(String risk) {
    switch (risk) {
      case 'Low':
        return primary;
      case 'Medium':
        return warning;
      case 'High':
        return danger;
      default:
        return textSecondary;
    }
  }

  static Color changeColor(double change) =>
      change >= 0 ? primary : danger;

  static String formatMarketCap(double? cap) {
    if (cap == null) return 'N/A';
    if (cap >= 1e12) return '\$${(cap / 1e12).toStringAsFixed(2)}T';
    if (cap >= 1e9) return '\$${(cap / 1e9).toStringAsFixed(2)}B';
    if (cap >= 1e6) return '\$${(cap / 1e6).toStringAsFixed(2)}M';
    return '\$${cap.toStringAsFixed(0)}';
  }
}

// ── Popular tickers for search suggestions ──
const List<Map<String, String>> kPopularTickers = [
  {'ticker': 'AAPL', 'name': 'Apple Inc.'},
  {'ticker': 'NVDA', 'name': 'NVIDIA Corp.'},
  {'ticker': 'MSFT', 'name': 'Microsoft Corp.'},
  {'ticker': 'TSLA', 'name': 'Tesla Inc.'},
  {'ticker': 'AMZN', 'name': 'Amazon.com'},
  {'ticker': 'GOOGL', 'name': 'Alphabet Inc.'},
  {'ticker': 'META', 'name': 'Meta Platforms'},
  {'ticker': 'BRK-B', 'name': 'Berkshire Hathaway'},
  {'ticker': '^IXIC', 'name': 'NASDAQ Composite'},
  {'ticker': 'BTC-USD', 'name': 'Bitcoin USD'},
  {'ticker': 'COIN', 'name': 'Coinbase Global'},
  {'ticker': 'PLTR', 'name': 'Palantir Tech.'},
];