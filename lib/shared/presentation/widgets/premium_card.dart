import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extensions.dart';

/// A standardized card component for InterviewPro to ensure design consistency.
/// Uses 16px radius and premium shadow by default.
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final BoxBorder? border;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: AppThemeExtensions.premiumCardDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
      ).copyWith(border: border),
      child: child,
    );
  }
}
