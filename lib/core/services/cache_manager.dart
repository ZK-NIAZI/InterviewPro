/// Cache entry with expiration
class CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  CacheEntry(this.data, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Simple in-memory cache manager for optimizing data fetching
class CacheManager {
  static final Map<String, CacheEntry> _cache = {};

  /// Get cached data if not expired
  static T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data as T?;
  }

  /// Cache data with TTL (Time To Live)
  static void set<T>(String key, T data, Duration ttl) {
    _cache[key] = CacheEntry<T>(data, DateTime.now().add(ttl));
  }

  /// Remove specific cache entry
  static void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cache
  static void clear() {
    _cache.clear();
  }

  /// Remove expired entries
  static void cleanExpired() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// Get cache statistics
  static Map<String, dynamic> getStats() {
    final expired = _cache.values.where((entry) => entry.isExpired).length;

    return {
      'totalEntries': _cache.length,
      'expiredEntries': expired,
      'activeEntries': _cache.length - expired,
    };
  }

  /// Cache keys for different data types
  static const String rolesKey = 'roles';
  static const String experienceLevelsKey = 'experience_levels';
  static const String interviewStatsKey = 'interview_stats';
  static const String recentInterviewsKey = 'recent_interviews';

  /// Default TTL values
  static const Duration rolesTTL = Duration(hours: 1);
  static const Duration experienceLevelsTTL = Duration(minutes: 30);
  static const Duration interviewStatsTTL = Duration(minutes: 5);
  static const Duration recentInterviewsTTL = Duration(minutes: 5);
}
