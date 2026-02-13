import 'package:flutter/material.dart';

/// Application color constants matching the HTML design
class AppColors {
  // Primary Colors (matching #e63746 from HTML)
  static const Color primary = Color(0xFFE63746);
  static const Color primaryLight = Color(0xFFFF6B7A);
  static const Color primaryDark = Color(0xFFB71C1C);

  // Background Colors (matching HTML design)
  static const Color backgroundLight = Color(0xFFF8F6F6);
  static const Color backgroundDark = Color(0xFF211112);
  // Surface Colors for Glassmorphism/Claymorphism
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9); // slate-100
  static const Color surfaceGlass = Color(0xCCFFFFFF); // 80% opacity white

  // Text Colors (matching HTML design)
  static const Color textPrimary = Color(0xFF1B0E0F); // text-main
  static const Color textSecondary = Color(0xFF6B7280); // text-sub (Gray-500)
  static const Color textLight = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors (matching HTML design)
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Gradient Tokens
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x66FFFFFF), Color(0x1AFFFFFF)],
  );

  // Shadow Tokens
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
