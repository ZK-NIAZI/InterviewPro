import 'package:flutter/foundation.dart';

/// Service for handling application errors and crash reporting
/// Currently logs to console, but designed to easily integrate
/// with services like Sentry, Firebase Crashlytics, etc.
class CrashReportingService {
  static final CrashReportingService _instance =
      CrashReportingService._internal();

  factory CrashReportingService() {
    return _instance;
  }

  CrashReportingService._internal();

  /// Initialize the crash reporting service
  Future<void> init() async {
    // Initialize external services here (e.g., Sentry.init)
    debugPrint('🛡️ CrashReportingService initialized');
  }

  /// Log a non-fatal error
  void recordError(dynamic error, StackTrace? stackTrace, {String? reason}) {
    // In production, this would send to Crashlytics/Sentry
    debugPrint('🔴 ERROR CAPTURED:');
    if (reason != null) debugPrint('Reason: $reason');
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack: $stackTrace');
    }
  }

  /// Log a message/breadcrumb
  void log(String message) {
    // In production, this adds a breadcrumb
    debugPrint('📝 LOG: $message');
  }

  /// Handle Flutter framework errors
  void handleFlutterError(FlutterErrorDetails details) {
    debugPrint('🔴 FLUTTER FRAMEWORK ERROR:');
    debugPrint('Exception: ${details.exception}');
    debugPrint('Library: ${details.library}');
    if (details.stack != null) {
      debugPrint('Stack: ${details.stack}');
    }

    // Send to external service
    recordError(
      details.exception,
      details.stack,
      reason: 'Flutter Framework Error',
    );
  }
}
