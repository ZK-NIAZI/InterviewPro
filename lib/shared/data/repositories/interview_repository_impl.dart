import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/interview_repository.dart';

/// Enhanced implementation of InterviewRepository with SharedPreferences persistence
/// Combines in-memory storage for performance with persistent storage for reliability
class InterviewRepositoryImpl implements InterviewRepository {
  // In-memory storage for performance
  final Map<String, Interview> _interviews = {};
  final Map<String, List<QuestionResponse>> _responses = {};

  // SharedPreferences keys
  static const String _interviewsKey = 'stored_interviews';
  static const String _responsesKey = 'stored_responses';

  // Initialization flag
  bool _isInitialized = false;

  InterviewRepositoryImpl();

  /// Initialize the repository by loading data from SharedPreferences
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      debugPrint(
        '🔄 Initializing InterviewRepository with persistent storage...',
      );
      final prefs = await SharedPreferences.getInstance();

      // Load interviews from SharedPreferences
      final interviewsJson = prefs.getString(_interviewsKey);
      if (interviewsJson != null) {
        final Map<String, dynamic> interviewsMap = json.decode(interviewsJson);
        for (final entry in interviewsMap.entries) {
          try {
            final interview = Interview.fromJson(entry.value);
            _interviews[entry.key] = interview;
          } catch (e) {
            debugPrint('⚠️ Failed to load interview ${entry.key}: $e');
          }
        }
        debugPrint(
          '✅ Loaded ${_interviews.length} interviews from persistent storage',
        );
      }

      // Load responses from SharedPreferences
      final responsesJson = prefs.getString(_responsesKey);
      if (responsesJson != null) {
        final Map<String, dynamic> responsesMap = json.decode(responsesJson);
        for (final entry in responsesMap.entries) {
          try {
            final responsesList = (entry.value as List)
                .map((r) => QuestionResponse.fromJson(r))
                .toList();
            _responses[entry.key] = responsesList;
          } catch (e) {
            debugPrint('⚠️ Failed to load responses for ${entry.key}: $e');
          }
        }
        debugPrint(
          '✅ Loaded responses for ${_responses.length} interviews from persistent storage',
        );
      }

      _isInitialized = true;
      debugPrint('✅ InterviewRepository initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing InterviewRepository: $e');
      _isInitialized = true; // Continue with empty state
    }
  }

  /// Save interviews to SharedPreferences
  Future<void> _persistInterviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interviewsMap = <String, dynamic>{};

      for (final entry in _interviews.entries) {
        try {
          interviewsMap[entry.key] = entry.value.toJson();
        } catch (e) {
          debugPrint('⚠️ Failed to serialize interview ${entry.key}: $e');
        }
      }

      await prefs.setString(_interviewsKey, json.encode(interviewsMap));
      debugPrint('💾 Persisted ${_interviews.length} interviews to storage');
    } catch (e) {
      debugPrint('❌ Error persisting interviews: $e');
    }
  }

  /// Save responses to SharedPreferences
  Future<void> _persistResponses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final responsesMap = <String, dynamic>{};

      for (final entry in _responses.entries) {
        try {
          responsesMap[entry.key] = entry.value.map((r) => r.toJson()).toList();
        } catch (e) {
          debugPrint('⚠️ Failed to serialize responses for ${entry.key}: $e');
        }
      }

      await prefs.setString(_responsesKey, json.encode(responsesMap));
      debugPrint(
        '💾 Persisted responses for ${_responses.length} interviews to storage',
      );
    } catch (e) {
      debugPrint('❌ Error persisting responses: $e');
    }
  }

  /// Clear all interviews (for testing)
  void clearAllInterviews() {
    _interviews.clear();
    _responses.clear();
    debugPrint('🧹 Cleared all interviews from memory');

    // Also clear from persistent storage
    _clearPersistentStorage();
  }

  /// Clear persistent storage (for testing)
  Future<void> _clearPersistentStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_interviewsKey);
      await prefs.remove(_responsesKey);
      debugPrint('🧹 Cleared persistent storage');
    } catch (e) {
      debugPrint('❌ Error clearing persistent storage: $e');
    }
  }

  @override
  Future<List<Interview>> getAllInterviews() async {
    await _ensureInitialized();

    final interviews = _interviews.values.toList();
    interviews.sort((a, b) => b.startTime.compareTo(a.startTime));
    debugPrint('✅ Loaded ${interviews.length} interviews from memory');
    return interviews;
  }

  @override
  Future<Interview?> getInterviewById(String id) async {
    await _ensureInitialized();

    final interview = _interviews[id];
    debugPrint('🔍 Looking for interview ID: $id');
    debugPrint('📊 Current interviews in memory: ${_interviews.keys.toList()}');
    debugPrint('📋 Total interviews stored: ${_interviews.length}');

    if (interview != null) {
      debugPrint(
        '✅ Found interview: ${interview.candidateName} (${interview.status})',
      );
    } else {
      debugPrint('❌ Interview not found in memory storage');
    }

    return interview;
  }

  @override
  Future<void> saveInterview(Interview interview) async {
    await _ensureInitialized();

    _interviews[interview.id] = interview;
    debugPrint('✅ Saved interview: ${interview.id}');
    debugPrint('👤 Candidate: ${interview.candidateName}');
    debugPrint('📊 Status: ${interview.status}');
    debugPrint('🗂️ Total interviews in memory: ${_interviews.length}');
    debugPrint('🔑 All interview IDs: ${_interviews.keys.toList()}');

    // Persist to SharedPreferences
    await _persistInterviews();
  }

  @override
  Future<void> updateInterview(Interview interview) async {
    await _ensureInitialized();

    _interviews[interview.id] = interview;
    debugPrint('✅ Updated interview: ${interview.id}');
    debugPrint('👤 Candidate: ${interview.candidateName}');
    debugPrint('📊 Status: ${interview.status}');
    debugPrint('🗂️ Total interviews in memory: ${_interviews.length}');

    // Persist to SharedPreferences
    await _persistInterviews();
  }

  @override
  Future<void> deleteInterview(String id) async {
    _interviews.remove(id);
    _responses.remove(id);
    debugPrint('✅ Deleted interview: $id');

    // Persist changes to SharedPreferences
    await _persistInterviews();
    await _persistResponses();
  }

  @override
  Future<List<Interview>> getInterviewsByStatus(InterviewStatus status) async {
    final allInterviews = await getAllInterviews();
    return allInterviews
        .where((interview) => interview.status == status)
        .toList();
  }

  @override
  Future<List<Interview>> getInterviewsByRole(Role role) async {
    final allInterviews = await getAllInterviews();
    return allInterviews.where((interview) => interview.role == role).toList();
  }

  @override
  Future<List<Interview>> getInterviewsByLevel(Level level) async {
    final allInterviews = await getAllInterviews();
    return allInterviews
        .where((interview) => interview.level == level)
        .toList();
  }

  @override
  Future<List<Interview>> getRecentInterviews({int limit = 10}) async {
    final allInterviews = await getAllInterviews();
    return allInterviews.take(limit).toList();
  }

  @override
  Future<List<Interview>> getInterviewsInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allInterviews = await getAllInterviews();
    return allInterviews.where((interview) {
      return interview.startTime.isAfter(startDate) &&
          interview.startTime.isBefore(endDate);
    }).toList();
  }

  @override
  Future<int> getInterviewCount() async {
    return _interviews.length;
  }

  @override
  Future<int> getInterviewCountByStatus(InterviewStatus status) async {
    final interviews = await getInterviewsByStatus(status);
    return interviews.length;
  }

  @override
  Future<bool> interviewExists(String id) async {
    return _interviews.containsKey(id);
  }

  @override
  Future<List<Interview>> getHighPerformingInterviews({
    double threshold = 70.0,
  }) async {
    final allInterviews = await getAllInterviews();
    return allInterviews.where((interview) {
      return interview.overallScore != null &&
          interview.overallScore! >= threshold;
    }).toList();
  }

  @override
  Future<Map<Role, double>> getAveragePerformanceByRole() async {
    final allInterviews = await getAllInterviews();
    final rolePerformance = <Role, List<double>>{};

    for (final interview in allInterviews) {
      if (interview.overallScore != null) {
        rolePerformance.putIfAbsent(interview.role, () => []);
        rolePerformance[interview.role]!.add(interview.overallScore!);
      }
    }

    final averages = <Role, double>{};
    for (final entry in rolePerformance.entries) {
      final scores = entry.value;
      if (scores.isNotEmpty) {
        averages[entry.key] = scores.reduce((a, b) => a + b) / scores.length;
      }
    }
    return averages;
  }

  @override
  Future<Map<Level, double>> getAveragePerformanceByLevel() async {
    final allInterviews = await getAllInterviews();
    final levelPerformance = <Level, List<double>>{};

    for (final interview in allInterviews) {
      if (interview.overallScore != null) {
        levelPerformance.putIfAbsent(interview.level, () => []);
        levelPerformance[interview.level]!.add(interview.overallScore!);
      }
    }

    final averages = <Level, double>{};
    for (final entry in levelPerformance.entries) {
      final scores = entry.value;
      if (scores.isNotEmpty) {
        averages[entry.key] = scores.reduce((a, b) => a + b) / scores.length;
      }
    }
    return averages;
  }

  @override
  Future<Map<String, dynamic>> getInterviewStatistics() async {
    final allInterviews = await getAllInterviews();
    final completedInterviews = allInterviews
        .where((i) => i.isCompleted)
        .toList();

    double averageScore = 0.0;
    if (completedInterviews.isNotEmpty) {
      final scores = completedInterviews
          .where((i) => i.overallScore != null)
          .map((i) => i.overallScore!)
          .toList();

      if (scores.isNotEmpty) {
        averageScore = scores.reduce((a, b) => a + b) / scores.length;
      }
    }

    return {
      'totalInterviews': allInterviews.length,
      'completedInterviews': completedInterviews.length,
      'inProgressInterviews': allInterviews.where((i) => i.isInProgress).length,
      'averageScore': averageScore,
      'highPerformers': completedInterviews
          .where((i) => i.overallScore != null && i.overallScore! >= 70.0)
          .length,
    };
  }

  @override
  Future<void> saveQuestionResponse(
    String interviewId,
    QuestionResponse response,
  ) async {
    _responses.putIfAbsent(interviewId, () => []);
    _responses[interviewId]!.add(response);
    debugPrint('✅ Saved question response for interview: $interviewId');

    // Persist responses to SharedPreferences
    await _persistResponses();
  }

  @override
  Future<List<QuestionResponse>> getQuestionResponses(
    String interviewId,
  ) async {
    final responses = _responses[interviewId] ?? [];
    responses.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return responses;
  }

  @override
  Future<void> updateInterviewProgress(
    String interviewId,
    int currentQuestionIndex,
  ) async {
    final interview = _interviews[interviewId];
    if (interview != null) {
      final updatedInterview = interview.copyWith(
        currentQuestionIndex: currentQuestionIndex,
      );
      await updateInterview(updatedInterview);
    }
  }

  @override
  Future<List<Interview>> getActiveInterviews() async {
    return await getInterviewsByStatus(InterviewStatus.inProgress);
  }

  @override
  Future<void> completeInterview(
    String interviewId, {
    required double technicalScore,
    double? softSkillsScore,
    double? overallScore,
  }) async {
    final interview = _interviews[interviewId];
    if (interview != null) {
      final updatedInterview = interview.copyWith(
        status: InterviewStatus.completed,
        endTime: DateTime.now(),
        technicalScore: technicalScore,
        softSkillsScore: softSkillsScore,
        overallScore: overallScore,
      );
      await updateInterview(updatedInterview);
    }
  }
}
