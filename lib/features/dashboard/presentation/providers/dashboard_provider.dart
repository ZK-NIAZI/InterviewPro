import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../shared/domain/entities/entities.dart';
import '../../../../shared/domain/repositories/repositories.dart';

/// Provider for managing dashboard state and data
class DashboardProvider extends ChangeNotifier {
  final InterviewRepository _interviewRepository;

  DashboardProvider(this._interviewRepository);

  bool _isLoading = false;
  String? _error;
  List<Interview> _recentInterviews = [];
  int _totalInterviews = 0;
  int _completedInterviews = 0;
  int _inProgressInterviews = 0;
  int _thisWeekInterviews = 0;
  double _averageScore = 0.0;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Interview> get recentInterviews => _recentInterviews;
  int get totalInterviews => _totalInterviews;
  int get completedInterviews => _completedInterviews;
  int get inProgressInterviews => _inProgressInterviews;
  int get thisWeekInterviews => _thisWeekInterviews;
  double get averageScore => _averageScore;

  /// Load dashboard data with enhanced error handling
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load recent interviews with timeout
      _recentInterviews = await _interviewRepository
          .getRecentInterviews(limit: 5)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout: Unable to load interviews');
            },
          );

      // Load statistics
      await _loadStatistics();

      debugPrint('✅ Dashboard data loaded successfully');
    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('❌ Error loading dashboard data: $_error');

      // Set fallback data to prevent UI crashes
      _setFallbackData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load interview statistics with enhanced error handling
  Future<void> _loadStatistics() async {
    try {
      // Get total interviews count with fallback
      _totalInterviews = await _interviewRepository
          .getInterviewCount()
          .timeout(const Duration(seconds: 5))
          .catchError((e) {
            debugPrint('Error getting interview count: $e');
            return 0;
          });

      // Get completed interviews count with fallback
      _completedInterviews = await _interviewRepository
          .getInterviewCountByStatus(InterviewStatus.completed)
          .timeout(const Duration(seconds: 5))
          .catchError((e) {
            debugPrint('Error getting completed interviews count: $e');
            return 0;
          });

      // Get in-progress interviews count with fallback
      _inProgressInterviews = await _interviewRepository
          .getInterviewCountByStatus(InterviewStatus.inProgress)
          .timeout(const Duration(seconds: 5))
          .catchError((e) {
            debugPrint('Error getting in-progress interviews count: $e');
            return 0;
          });

      // Get this week's interviews with fallback
      await _loadThisWeekInterviews();

      // Calculate average score from completed interviews with fallback
      await _calculateAverageScore();

      debugPrint('✅ Statistics loaded successfully');
    } catch (e) {
      debugPrint('❌ Error loading statistics: $e');
      // Statistics errors don't prevent dashboard from working
    }
  }

  /// Load this week's interviews with error handling
  Future<void> _loadThisWeekInterviews() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      final thisWeekInterviews = await _interviewRepository
          .getInterviewsInDateRange(startOfWeek, endOfWeek)
          .timeout(const Duration(seconds: 5));

      _thisWeekInterviews = thisWeekInterviews.length;
    } catch (e) {
      debugPrint('Error loading this week interviews: $e');
      _thisWeekInterviews = 0;
    }
  }

  /// Calculate average score with error handling
  Future<void> _calculateAverageScore() async {
    try {
      final completedInterviews = await _interviewRepository
          .getInterviewsByStatus(InterviewStatus.completed)
          .timeout(const Duration(seconds: 5));

      if (completedInterviews.isNotEmpty) {
        // Filter interviews that have technical scores and calculate average
        final interviewsWithScores = completedInterviews
            .where(
              (interview) =>
                  interview.technicalScore != null ||
                  interview.overallScore != null,
            )
            .toList();

        if (interviewsWithScores.isNotEmpty) {
          final totalScore = interviewsWithScores
              .map(
                (interview) =>
                    interview.overallScore ?? interview.technicalScore ?? 0.0,
              )
              .reduce((a, b) => a + b);
          _averageScore = totalScore / interviewsWithScores.length;
        } else {
          _averageScore = 0.0;
        }
      } else {
        _averageScore = 0.0;
      }
    } catch (e) {
      debugPrint('Error calculating average score: $e');
      _averageScore = 0.0;
    }
  }

  /// Set fallback data when loading fails
  void _setFallbackData() {
    _recentInterviews = [];
    _totalInterviews = 0;
    _completedInterviews = 0;
    _inProgressInterviews = 0;
    _thisWeekInterviews = 0;
    _averageScore = 0.0;
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('timeout')) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.toString().contains('network')) {
      return 'Network error. Please try again later.';
    } else if (error.toString().contains('permission')) {
      return 'Permission denied. Please check your access rights.';
    } else {
      return 'Unable to load data. Please try again.';
    }
  }

  /// Refresh dashboard data with retry mechanism
  Future<void> refresh({int retryCount = 0}) async {
    const maxRetries = 2;

    try {
      await loadDashboardData();
    } catch (e) {
      if (retryCount < maxRetries) {
        debugPrint(
          'Retrying dashboard refresh (${retryCount + 1}/$maxRetries)',
        );
        await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        return refresh(retryCount: retryCount + 1);
      } else {
        rethrow;
      }
    }
  }

  /// Add a new interview and refresh data with error handling
  Future<void> addInterview(Interview interview) async {
    try {
      await _interviewRepository.saveInterview(interview);
      await refresh();
      debugPrint('✅ Interview added successfully');
    } catch (e) {
      debugPrint('❌ Error adding interview: $e');
      rethrow;
    }
  }

  /// Update an existing interview and refresh data with error handling
  Future<void> updateInterview(Interview interview) async {
    try {
      await _interviewRepository.updateInterview(interview);
      await refresh();
      debugPrint('✅ Interview updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating interview: $e');
      rethrow;
    }
  }

  /// Delete an interview and refresh data with error handling
  Future<void> deleteInterview(String interviewId) async {
    try {
      await _interviewRepository.deleteInterview(interviewId);
      await refresh();
      debugPrint('✅ Interview deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting interview: $e');
      rethrow;
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}
