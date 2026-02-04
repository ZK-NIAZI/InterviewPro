import 'package:flutter_test/flutter_test.dart';
import 'package:interview_pro_app/core/services/cache_manager.dart';
import 'package:interview_pro_app/core/services/service_locator.dart';
import 'platform_mock_helper.dart';

/// Test helper class for managing test isolation and setup
class TestHelper {
  /// Setup clean test environment
  static Future<void> setupTest() async {
    // Setup platform mocks first
    PlatformMockHelper.setupMocks();

    // Clear all caches to prevent test interference
    CacheManager.clear();

    // Note: Service locator reset is handled per test as needed
    // since some tests need specific mock setups
  }

  /// Cleanup after test
  static Future<void> teardownTest() async {
    // Clear all caches
    CacheManager.clear();

    // Clean up expired entries
    CacheManager.cleanExpired();

    // Teardown platform mocks
    PlatformMockHelper.teardownMocks();
  }

  /// Reset service locator (use carefully - only when needed)
  static Future<void> resetServiceLocator() async {
    try {
      await sl.reset();
    } catch (e) {
      // Service locator might not be initialized, ignore error
    }
  }

  /// Clear specific cache keys commonly used in tests
  static void clearTestCaches() {
    // Clear common cache keys that might interfere with tests
    final commonKeys = [
      'questions_all_all_all',
      'questions_technical_all_all',
      'questions_all_beginner_all',
      'question_categories',
      'question_stats',
      CacheManager.rolesKey,
      CacheManager.experienceLevelsKey,
      CacheManager.interviewStatsKey,
      CacheManager.recentInterviewsKey,
    ];

    for (final key in commonKeys) {
      CacheManager.remove(key);
    }
  }

  /// Get cache statistics for debugging
  static Map<String, dynamic> getCacheStats() {
    return CacheManager.getStats();
  }
}
