import 'package:flutter/material.dart';
import '../../../../shared/domain/entities/entities.dart';
import '../../../../shared/domain/repositories/interview_repository.dart';

/// Provider for managing interview history state
class HistoryProvider extends ChangeNotifier {
  final InterviewRepository _interviewRepository;

  HistoryProvider(this._interviewRepository);

  bool _isLoading = false;
  int _selectedFilterIndex = 0;
  List<Interview> _allInterviews = [];
  List<Interview> _filteredInterviews = [];

  // Statistics
  int _totalInterviews = 0;
  double _averageScore = 0.0;
  int _hiredCount = 0;

  // Getters
  bool get isLoading => _isLoading;
  int get selectedFilterIndex => _selectedFilterIndex;
  List<Interview> get filteredInterviews => _filteredInterviews;
  int get totalInterviews => _totalInterviews;
  double get averageScore => _averageScore;
  int get hiredCount => _hiredCount;

  /// Sets the loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Updates the selected filter index and applies filter
  void updateFilter(int index) {
    _selectedFilterIndex = index;
    _applyFilter();
    notifyListeners();
  }

  /// Loads interview history data
  Future<void> loadHistoryData() async {
    setLoading(true);

    try {
      // Load all interviews
      _allInterviews = await _interviewRepository.getAllInterviews();

      // Calculate statistics
      await _calculateStatistics();

      // Apply current filter
      _applyFilter();

      debugPrint('✅ Loaded ${_allInterviews.length} interviews for history');
    } catch (e) {
      debugPrint('❌ Error loading history data: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Calculate statistics from all interviews
  Future<void> _calculateStatistics() async {
    try {
      _totalInterviews = _allInterviews.length;

      // Calculate average score from completed interviews with scores
      final completedWithScores = _allInterviews
          .where(
            (interview) =>
                interview.isCompleted && interview.overallScore != null,
          )
          .toList();

      if (completedWithScores.isNotEmpty) {
        final totalScore = completedWithScores
            .map((interview) => interview.overallScore!)
            .reduce((a, b) => a + b);
        _averageScore = totalScore / completedWithScores.length;
      } else {
        _averageScore = 0.0;
      }

      // Calculate hired count (interviews with score >= 70%)
      _hiredCount = completedWithScores
          .where((interview) => interview.overallScore! >= 70.0)
          .length;
    } catch (e) {
      debugPrint('❌ Error calculating statistics: $e');
      _totalInterviews = 0;
      _averageScore = 0.0;
      _hiredCount = 0;
    }
  }

  /// Apply filter based on selected index
  void _applyFilter() {
    final now = DateTime.now();

    switch (_selectedFilterIndex) {
      case 0: // All
        _filteredInterviews = List.from(_allInterviews);
        break;
      case 1: // This Week
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        _filteredInterviews = _allInterviews
            .where(
              (interview) =>
                  interview.startTime.isAfter(startOfWeek) &&
                  interview.startTime.isBefore(endOfWeek),
            )
            .toList();
        break;
      case 2: // This Month
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        _filteredInterviews = _allInterviews
            .where(
              (interview) =>
                  interview.startTime.isAfter(startOfMonth) &&
                  interview.startTime.isBefore(endOfMonth),
            )
            .toList();
        break;
      default:
        _filteredInterviews = List.from(_allInterviews);
    }

    // Sort by start time (most recent first)
    _filteredInterviews.sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  /// Refreshes the interview history data
  Future<void> refreshData() async {
    await loadHistoryData();
  }

  /// Delete an interview and refresh data
  Future<void> deleteInterview(String interviewId) async {
    try {
      await _interviewRepository.deleteInterview(interviewId);
      await refreshData();
    } catch (e) {
      debugPrint('❌ Error deleting interview: $e');
      rethrow;
    }
  }

  /// Get filter display name
  String getFilterDisplayName(int index) {
    switch (index) {
      case 0:
        return 'All';
      case 1:
        return 'This Week';
      case 2:
        return 'This Month';
      default:
        return 'All';
    }
  }
}
