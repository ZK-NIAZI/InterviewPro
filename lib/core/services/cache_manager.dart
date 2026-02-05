import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Cache entry with expiration and metadata
class CacheEntry<T> {
  final T data;
  final DateTime expiresAt;
  final DateTime createdAt;
  final String checksum;

  CacheEntry(this.data, this.expiresAt, this.createdAt, this.checksum);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if data integrity is maintained
  bool isValid(String expectedChecksum) => checksum == expectedChecksum;
}

/// Enhanced in-memory cache manager with security and performance optimizations
class CacheManager {
  static final Map<String, CacheEntry> _cache = {};
  static const int _maxCacheSize = 1000; // Prevent memory overflow
  static const Duration _defaultCleanupInterval = Duration(minutes: 10);
  static DateTime? _lastCleanup;

  /// Get cached data if not expired and valid
  static T? get<T>(String key) {
    _performPeriodicCleanup();

    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    // Validate data integrity for sensitive data
    if (_isSensitiveKey(key)) {
      final expectedChecksum = _generateChecksum(entry.data.toString());
      if (!entry.isValid(expectedChecksum)) {
        _cache.remove(key);
        return null;
      }
    }

    return entry.data as T?;
  }

  /// Cache data with TTL and integrity checking
  static void set<T>(String key, T data, Duration ttl) {
    _performPeriodicCleanup();

    // Prevent cache overflow
    if (_cache.length >= _maxCacheSize) {
      _evictOldestEntries();
    }

    // Validate input
    if (key.isEmpty || ttl.inMilliseconds <= 0) {
      return;
    }

    final now = DateTime.now();
    final checksum = _generateChecksum(data.toString());

    _cache[key] = CacheEntry<T>(data, now.add(ttl), now, checksum);
  }

  /// Remove specific cache entry securely
  static void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cache securely
  static void clear() {
    _cache.clear();
    _lastCleanup = DateTime.now();
  }

  /// Remove expired entries and perform maintenance
  static void cleanExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => entry.isExpired);
    _lastCleanup = now;
  }

  /// Evict oldest entries when cache is full
  static void _evictOldestEntries() {
    if (_cache.isEmpty) return;

    // Sort by creation time and remove oldest 10%
    final entries = _cache.entries.toList();
    entries.sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));

    final toRemove = (entries.length * 0.1).ceil();
    for (int i = 0; i < toRemove && i < entries.length; i++) {
      _cache.remove(entries[i].key);
    }
  }

  /// Perform periodic cleanup if needed
  static void _performPeriodicCleanup() {
    final now = DateTime.now();
    if (_lastCleanup == null ||
        now.difference(_lastCleanup!).compareTo(_defaultCleanupInterval) > 0) {
      cleanExpired();
    }
  }

  /// Generate checksum for data integrity
  static String _generateChecksum(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if key contains sensitive data
  static bool _isSensitiveKey(String key) {
    const sensitiveKeys = [
      'current_interview_session',
      'session_questions',
      'user_data',
      'auth_token',
    ];
    return sensitiveKeys.any((sensitive) => key.contains(sensitive));
  }

  /// Get comprehensive cache statistics
  static Map<String, dynamic> getStats() {
    final expired = _cache.values.where((entry) => entry.isExpired).length;
    final sensitive = _cache.keys.where(_isSensitiveKey).length;

    // Calculate memory usage estimate
    final totalEntries = _cache.length;
    final estimatedMemoryKB = totalEntries * 2; // Rough estimate: 2KB per entry

    return {
      'totalEntries': totalEntries,
      'expiredEntries': expired,
      'activeEntries': totalEntries - expired,
      'sensitiveEntries': sensitive,
      'estimatedMemoryKB': estimatedMemoryKB,
      'maxCacheSize': _maxCacheSize,
      'lastCleanup': _lastCleanup?.toIso8601String(),
      'cacheUtilization': (totalEntries / _maxCacheSize * 100).toStringAsFixed(
        1,
      ),
    };
  }

  /// Validate cache health and integrity
  static Map<String, dynamic> validateCacheHealth() {
    int corruptedEntries = 0;
    int validEntries = 0;

    for (final entry in _cache.entries) {
      if (_isSensitiveKey(entry.key)) {
        final expectedChecksum = _generateChecksum(entry.value.data.toString());
        if (entry.value.isValid(expectedChecksum)) {
          validEntries++;
        } else {
          corruptedEntries++;
        }
      } else {
        validEntries++;
      }
    }

    return {
      'validEntries': validEntries,
      'corruptedEntries': corruptedEntries,
      'healthScore': validEntries / (validEntries + corruptedEntries) * 100,
      'recommendCleanup': corruptedEntries > 0,
    };
  }

  /// Cache keys for different data types
  static const String rolesKey = 'roles';
  static const String experienceLevelsKey = 'experience_levels';
  static const String interviewStatsKey = 'interview_stats';
  static const String recentInterviewsKey = 'recent_interviews';
  static const String dashboardDataKey = 'dashboard_data';
  static const String historyDataKey = 'history_data';

  /// Enhanced TTL values for different data types
  static const Duration rolesTTL = Duration(hours: 2);
  static const Duration experienceLevelsTTL = Duration(hours: 1);
  static const Duration interviewStatsTTL = Duration(minutes: 10);
  static const Duration recentInterviewsTTL = Duration(minutes: 5);
  static const Duration dashboardDataTTL = Duration(minutes: 3);
  static const Duration historyDataTTL = Duration(minutes: 5);
  static const Duration sessionDataTTL = Duration(hours: 24);
}
