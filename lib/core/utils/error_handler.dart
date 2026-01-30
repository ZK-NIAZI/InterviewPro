import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import 'ui_helpers.dart';

/// Utility class for handling errors consistently across the app
class ErrorHandler {
  /// Handles and logs errors
  static void handleError(
    Object error,
    StackTrace stackTrace, {
    String? context,
  }) {
    // Log error for debugging
    debugPrint('Error in ${context ?? 'Unknown context'}: $error');
    debugPrint('Stack trace: $stackTrace');

    // In a real app, you might want to send this to a crash reporting service
    // like Firebase Crashlytics or Sentry
  }

  /// Shows error message to user
  static void showErrorToUser(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    UIHelpers.showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  /// Shows generic error message
  static void showGenericError(BuildContext context) {
    showErrorToUser(context, AppStrings.error);
  }

  /// Handles async operations with error handling
  static Future<T?> handleAsyncOperation<T>(
    Future<T> operation, {
    required BuildContext context,
    String? errorMessage,
    String? operationContext,
  }) async {
    try {
      return await operation;
    } catch (error, stackTrace) {
      handleError(error, stackTrace, context: operationContext);
      showErrorToUser(context, errorMessage ?? AppStrings.error);
      return null;
    }
  }

  /// Wraps a function with error handling
  static void safeExecute(
    VoidCallback operation, {
    BuildContext? context,
    String? errorMessage,
    String? operationContext,
  }) {
    try {
      operation();
    } catch (error, stackTrace) {
      handleError(error, stackTrace, context: operationContext);
      if (context != null) {
        showErrorToUser(context, errorMessage ?? AppStrings.error);
      }
    }
  }

  /// Gets user-friendly error message from exception
  static String getUserFriendlyMessage(Object error) {
    if (error is FormatException) {
      return 'Invalid data format';
    } else if (error is TimeoutException) {
      return 'Operation timed out';
    } else if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return 'Network connection error';
    } else {
      return AppStrings.error;
    }
  }
}

/// Custom exception classes for better error handling
class InterviewException implements Exception {
  final String message;
  final String? code;

  const InterviewException(this.message, {this.code});

  @override
  String toString() => 'InterviewException: $message';
}

class ValidationException extends InterviewException {
  const ValidationException(super.message) : super(code: 'VALIDATION_ERROR');
}

class DataException extends InterviewException {
  const DataException(super.message) : super(code: 'DATA_ERROR');
}

class NetworkException extends InterviewException {
  const NetworkException(super.message) : super(code: 'NETWORK_ERROR');
}
