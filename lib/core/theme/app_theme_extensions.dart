import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Design system extensions for premium UI effects
class AppThemeExtensions {
  /// Glassmorphism decoration for headers and cards
  static BoxDecoration glassDecoration({
    BorderRadius? borderRadius,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: AppColors.surfaceGlass,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: showBorder
          ? Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5)
          : null,
      boxShadow: AppColors.softShadow,
    );
  }

  /// Claymorphism decoration for interactive buttons
  static BoxDecoration clayDecoration({
    required Color color,
    BorderRadius? borderRadius,
    bool isPressed = false,
  }) {
    final br = borderRadius ?? BorderRadius.circular(16);

    if (isPressed) {
      return BoxDecoration(
        color: color,
        borderRadius: br,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            offset: const Offset(-2, -2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      );
    }

    return BoxDecoration(
      color: color,
      borderRadius: br,
      boxShadow: [
        // Bottom right dark shadow
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(4, 4),
          blurRadius: 8,
        ),
        // Top left light highlight
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.4),
          offset: const Offset(-4, -4),
          blurRadius: 8,
        ),
      ],
    );
  }

  /// Premium card decoration with soft shadows
  static BoxDecoration premiumCardDecoration({
    BorderRadius? borderRadius,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      boxShadow: AppColors.softShadow,
    );
  }

  /// Gradient background for primary actions
  static BoxDecoration primaryGradientDecoration({BorderRadius? borderRadius}) {
    return BoxDecoration(
      gradient: AppColors.primaryGradient,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      boxShadow: AppColors.premiumShadow,
    );
  }
}
