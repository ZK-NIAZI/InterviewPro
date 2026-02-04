import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../shared/domain/entities/entities.dart';
import '../../../../shared/domain/repositories/repositories.dart';

/// Provider for managing dashboard state and data
class DashboardProvider extends ChangeNotifier {
  final InterviewRepository _interviewRepository;

  DashboardProvider(this._interviewRepository);

  bool _isLoading = false;
  List<Interview> _recentInterviews = [];
  int _totalInterviews = 0;
  int _completedInterviews = 0;
  int _inProgressInterviews = 0;
  int _thisWeekInterviews = 0;
  double _averageScore = 0.0;

  // Getters
  bool get isLoading => _isLoading;
  List<Interview> get recentInterviews => _recentInterviews;
  int get totalInterviews => _totalInterviews;
  int get completedInterviews => _completedInterviews;
  int get inProgressInterviews => _inProgressInterviews;
  int get thisWeekInterviews => _thisWeekInterviews;
  double get averageScore => _averageScore;

  /// Load dashboard data
  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load recent interviews
      _recentInterviews = await _interviewRepository.getRecentInterviews(
        limit: 5,
      );

      // Load statistics
      await _loadStatistics();
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load interview statistics
  Future<void> _loadStatistics() async {
    try {
      // Get total interviews count
      _totalInterviews = await _interviewRepository.getInterviewCount();

      // Get completed interviews count
      _completedInterviews = await _interviewRepository
          .getInterviewCountByStatus(InterviewStatus.completed);

      // Get in-progress interviews count
      _inProgressInterviews = await _interviewRepository
          .getInterviewCountByStatus(InterviewStatus.inProgress);

      // Get this week's interviews
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      final thisWeekInterviews = await _interviewRepository
          .getInterviewsInDateRange(startOfWeek, endOfWeek);
      _thisWeekInterviews = thisWeekInterviews.length;

      // Calculate average score from completed interviews
      final completedInterviews = await _interviewRepository
          .getInterviewsByStatus(InterviewStatus.completed);

      if (completedInterviews.isNotEmpty) {
        // Filter interviews that have scores and calculate average
        final interviewsWithScores = completedInterviews
            .where((interview) => interview.overallScore != null)
            .toList();

        if (interviewsWithScores.isNotEmpty) {
          final totalScore = interviewsWithScores
              .map((interview) => interview.overallScore!)
              .reduce((a, b) => a + b);
          _averageScore = totalScore / interviewsWithScores.length;
        } else {
          _averageScore = 0.0;
        }
      } else {
        _averageScore = 0.0;
      }
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboardData();
  }

  /// Add a new interview and refresh data
  Future<void> addInterview(Interview interview) async {
    try {
      await _interviewRepository.saveInterview(interview);
      await refresh();
    } catch (e) {
      debugPrint('Error adding interview: $e');
      rethrow;
    }
  }

  /// Update an existing interview and refresh data
  Future<void> updateInterview(Interview interview) async {
    try {
      await _interviewRepository.updateInterview(interview);
      await refresh();
    } catch (e) {
      debugPrint('Error updating interview: $e');
      rethrow;
    }
  }

  /// Delete an interview and refresh data
  Future<void> deleteInterview(String interviewId) async {
    try {
      await _interviewRepository.deleteInterview(interviewId);
      await refresh();
    } catch (e) {
      debugPrint('Error deleting interview: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}
