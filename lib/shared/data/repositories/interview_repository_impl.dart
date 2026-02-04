import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/interview_repository.dart';

/// Simple in-memory implementation of InterviewRepository
/// Can be easily replaced with Appwrite implementation later
class InterviewRepositoryImpl implements InterviewRepository {
  // In-memory storage
  final Map<String, Interview> _interviews = {};
  final Map<String, List<QuestionResponse>> _responses = {};

  InterviewRepositoryImpl();

  /// Clear all interviews (for testing)
  void clearAllInterviews() {
    _interviews.clear();
    _responses.clear();
    debugPrint('🧹 Cleared all interviews from memory');
  }

  @override
  Future<List<Interview>> getAllInterviews() async {
    final interviews = _interviews.values.toList();
    interviews.sort((a, b) => b.startTime.compareTo(a.startTime));
    debugPrint('✅ Loaded ${interviews.length} interviews from memory');
    return interviews;
  }

  @override
  Future<Interview?> getInterviewById(String id) async {
    return _interviews[id];
  }

  @override
  Future<void> saveInterview(Interview interview) async {
    _interviews[interview.id] = interview;
    debugPrint('✅ Saved interview: ${interview.id}');
  }

  @override
  Future<void> updateInterview(Interview interview) async {
    _interviews[interview.id] = interview;
    debugPrint('✅ Updated interview: ${interview.id}');
  }

  @override
  Future<void> deleteInterview(String id) async {
    _interviews.remove(id);
    _responses.remove(id);
    debugPrint('✅ Deleted interview: $id');
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
