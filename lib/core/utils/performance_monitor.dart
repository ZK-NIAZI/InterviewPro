import 'dart:async';
import 'package:flutter/foundation.dart';

/// Performance monitoring utility for tracking app performance
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<Duration>> _measurements = {};
  static int _widgetRebuildCount = 0;
  static int _networkRequestCount = 0;

  /// Start timing an operation
  static void startTimer(String operationName) {
    _startTimes[operationName] = DateTime.now();
  }

  /// End timing an operation and record the duration
  static Duration? endTimer(String operationName) {
    final startTime = _startTimes.remove(operationName);
    if (startTime == null) return null;

    final duration = DateTime.now().difference(startTime);

    _measurements.putIfAbsent(operationName, () => []).add(duration);

    if (kDebugMode) {
      debugPrint('⏱️ $operationName took ${duration.inMilliseconds}ms');
    }

    return duration;
  }

  /// Record a widget rebuild
  static void recordWidgetRebuild() {
    _widgetRebuildCount++;
  }

  /// Record a network request
  static void recordNetworkRequest() {
    _networkRequestCount++;
  }

  /// Get performance statistics
  static Map<String, dynamic> getStats() {
    final stats = <String, dynamic>{
      'widgetRebuilds': _widgetRebuildCount,
      'networkRequests': _networkRequestCount,
      'operations': <String, dynamic>{},
    };

    for (final entry in _measurements.entries) {
      final durations = entry.value;
      if (durations.isEmpty) continue;

      final totalMs = durations.fold<int>(
        0,
        (sum, d) => sum + d.inMilliseconds,
      );
      final avgMs = totalMs / durations.length;
      final minMs = durations
          .map((d) => d.inMilliseconds)
          .reduce((a, b) => a < b ? a : b);
      final maxMs = durations
          .map((d) => d.inMilliseconds)
          .reduce((a, b) => a > b ? a : b);

      stats['operations'][entry.key] = {
        'count': durations.length,
        'totalMs': totalMs,
        'avgMs': avgMs.round(),
        'minMs': minMs,
        'maxMs': maxMs,
      };
    }

    return stats;
  }

  /// Reset all statistics
  static void reset() {
    _startTimes.clear();
    _measurements.clear();
    _widgetRebuildCount = 0;
    _networkRequestCount = 0;
  }

  /// Print performance report
  static void printReport() {
    if (!kDebugMode) return;

    final stats = getStats();
    debugPrint('\n📊 PERFORMANCE REPORT');
    debugPrint('═' * 50);
    debugPrint('Widget Rebuilds: ${stats['widgetRebuilds']}');
    debugPrint('Network Requests: ${stats['networkRequests']}');
    debugPrint('\nOperations:');

    final operations = stats['operations'] as Map<String, dynamic>;
    for (final entry in operations.entries) {
      final op = entry.value as Map<String, dynamic>;
      debugPrint('  ${entry.key}:');
      debugPrint('    Count: ${op['count']}');
      debugPrint('    Avg: ${op['avgMs']}ms');
      debugPrint('    Min: ${op['minMs']}ms');
      debugPrint('    Max: ${op['maxMs']}ms');
    }
    debugPrint('═' * 50);
  }

  /// Measure execution time of a function
  static Future<T> measure<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startTimer(operationName);
    try {
      return await operation();
    } finally {
      endTimer(operationName);
    }
  }

  /// Measure execution time of a synchronous function
  static T measureSync<T>(String operationName, T Function() operation) {
    startTimer(operationName);
    try {
      return operation();
    } finally {
      endTimer(operationName);
    }
  }
}
