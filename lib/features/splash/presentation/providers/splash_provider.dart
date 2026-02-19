import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/providers/auth_provider.dart';

/// Provider for managing splash screen state and navigation
class SplashProvider extends ChangeNotifier {
  bool _isLoading = true;
  final AuthProvider _authProvider;

  SplashProvider(this._authProvider);

  bool get isLoading => _isLoading;

  /// Start the splash screen timer and navigate to dashboard after delay
  Future<void> startSplashTimer(BuildContext context) async {
    // Attempt silent sign-in in background
    // We don't await this fully if it takes too long, but we start it here
    // to ensure auth state is ready (or failed) by the time we hit dashboard
    final minSplashTime = Future.delayed(
      Duration(milliseconds: AppConstants.splashDuration),
    );

    final silentLogin = _authProvider.trySilentSignIn();

    // Wait for both, but dont block indefinitely on network
    await Future.wait([
      minSplashTime,
      // Timeout silent login so we don't hang if network is flaky
      silentLogin.timeout(const Duration(seconds: 3), onTimeout: () => null),
    ]);

    if (context.mounted) {
      _navigateToDashboard(context);
    }
  }

  /// Navigate to the dashboard page
  void _navigateToDashboard(BuildContext context) {
    if (context.mounted) {
      _isLoading = false;
      notifyListeners();
      context.go(AppRouter.dashboard);
    }
  }
}
