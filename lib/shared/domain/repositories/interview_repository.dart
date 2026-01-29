import '../entities/entities.dart';

/// Repository interface for managing interview data
abstract class InterviewRepository {
  /// Get all interviews
  Future<List<Interview>> getAllInterviews();

  /// Get interview by ID
  Future<Interview?> getInterviewById(String id);

  /// Save interview
  Future<void> saveInterview(Interview interview);

  /// Update interview
  Future<void> updateInterview(Interview interview);

  /// Delete interview
  Future<void> deleteInterview(String id);

  /// Get interviews by status
  Future<List<Interview>> getInterviewsByStatus(InterviewStatus status);

  /// Get interviews by role
  Future<List<Interview>> getInterviewsByRole(Role role);

  /// Get interviews by level
  Future<List<Interview>> getInterviewsByLevel(Level level);

  /// Get recent interviews
  Future<List<Interview>> getRecentInterviews({int limit = 10});

  /// Get interviews within date range
  Future<List<Interview>> getInterviewsInDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get total count of interviews
  Future<int> getInterviewCount();

  /// Get count of interviews by status
  Future<int> getInterviewCountByStatus(InterviewStatus status);

  /// Check if interview exists
  Future<bool> interviewExists(String id);
}
