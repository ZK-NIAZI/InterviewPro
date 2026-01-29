import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_router.dart';

/// Provider for managing splash screen state and navigation
class SplashProvider extends ChangeNotifier {
  bool _isLoading = true;
  Timer? _timer;

  bool get isLoading => _isLoading;

  /// Start the splash screen timer and navigate to dashboard after delay
  void startSplashTimer(BuildContext context) {
    _timer = Timer(
      Duration(milliseconds: AppConstants.splashDuration),
      () => _navigateToDashboard(context),
    );
  }

  /// Navigate to the dashboard page
  void _navigateToDashboard(BuildContext context) {
    if (context.mounted) {
      _isLoading = false;
      notifyListeners();
      context.go(AppRouter.dashboard);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
