import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Retry configuration
class RetryConfig {
  final int maxRetries;
  final Duration baseDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryConfig({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
  });
}

/// Retry helper for network operations
class RetryHelper {
  /// Execute operation with retry logic and exponential backoff
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    RetryConfig config = const RetryConfig(),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = config.baseDelay;

    while (attempt < config.maxRetries) {
      attempt++;

      try {
        debugPrint('🔄 Attempt $attempt/${config.maxRetries}');
        return await operation();
      } catch (error) {
        debugPrint('❌ Attempt $attempt failed: $error');

        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(error)) {
          debugPrint('🚫 Error not retryable, giving up');
          rethrow;
        }

        // If this was the last attempt, rethrow the error
        if (attempt >= config.maxRetries) {
          debugPrint('🔴 Max retries exceeded, giving up');
          rethrow;
        }

        // Wait before next attempt with exponential backoff
        debugPrint('⏳ Waiting ${delay.inSeconds}s before retry...');
        await Future.delayed(delay);

        // Calculate next delay with exponential backoff
        delay = Duration(
          milliseconds: min(
            (delay.inMilliseconds * config.backoffMultiplier).round(),
            config.maxDelay.inMilliseconds,
          ),
        );
      }
    }

    throw Exception('Max retries exceeded');
  }

  /// Check if error is retryable (network errors, timeouts, etc.)
  static bool isRetryableError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Common retryable error patterns
    return errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no internet') ||
        errorString.contains('server error') ||
        errorString.contains('503') ||
        errorString.contains('502') ||
        errorString.contains('504');
  }

  /// Predefined retry configs for different scenarios
  static const RetryConfig networkConfig = RetryConfig(
    maxRetries: 3,
    baseDelay: Duration(seconds: 2),
    backoffMultiplier: 2.0,
    maxDelay: Duration(seconds: 30),
  );

  static const RetryConfig quickConfig = RetryConfig(
    maxRetries: 2,
    baseDelay: Duration(milliseconds: 500),
    backoffMultiplier: 1.5,
    maxDelay: Duration(seconds: 5),
  );

  static const RetryConfig persistentConfig = RetryConfig(
    maxRetries: 5,
    baseDelay: Duration(seconds: 1),
    backoffMultiplier: 2.0,
    maxDelay: Duration(minutes: 1),
  );
}
