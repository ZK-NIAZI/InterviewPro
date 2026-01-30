import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Utility class for common UI patterns and helpers
class UIHelpers {
  /// Creates a standard elevated button with consistent styling
  static Widget createElevatedButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    double? height,
    double? borderRadius,
    bool isEnabled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height ?? AppDimensions.buttonHeightLarge,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 8,
          shadowColor: (backgroundColor ?? AppColors.primary).withValues(
            alpha: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppDimensions.radiusMedium,
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// Creates a standard card with consistent styling
  static Widget createCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppDimensions.radiusMedium,
        ),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: AppDimensions.cardBlurRadius,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: child,
    );
  }

  /// Creates a standard dialog
  static Future<T?> showStandardDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions:
            actions ??
            [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
      ),
    );
  }

  /// Creates a standard snackbar
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppColors.primary,
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }

  /// Creates a loading indicator
  static Widget createLoadingIndicator({Color? color, double? size}) {
    return Center(
      child: SizedBox(
        width: size ?? AppDimensions.iconLarge,
        height: size ?? AppDimensions.iconLarge,
        child: CircularProgressIndicator(color: color ?? AppColors.primary),
      ),
    );
  }

  /// Creates a standard section header
  static Widget createSectionHeader({
    required String title,
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// Creates a standard divider
  static Widget createDivider({EdgeInsetsGeometry? margin, Color? color}) {
    return Container(
      height: 1,
      margin:
          margin ?? const EdgeInsets.only(left: AppDimensions.paddingMedium),
      color: color ?? const Color(0xFFF3E8E9),
    );
  }

  /// Creates a standard back button
  static Widget createBackButton({
    required VoidCallback onPressed,
    IconData? icon,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppDimensions.buttonHeightSmall,
        height: AppDimensions.buttonHeightSmall,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon ?? Icons.arrow_back,
          size: AppDimensions.iconMedium,
          color: color ?? Colors.black,
        ),
      ),
    );
  }

  /// Creates a standard toggle switch
  static Widget createToggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 51,
        height: 31,
        decoration: BoxDecoration(
          color: value
              ? (activeColor ?? AppColors.primary)
              : const Color(0xFFF3E8E9),
          borderRadius: BorderRadius.circular(15.5),
        ),
        child: AnimatedAlign(
          duration: const Duration(
            milliseconds: AppDimensions.animationDurationShort,
          ),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 27,
            height: 27,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
