import 'package:equatable/equatable.dart';
import 'enums.dart';
import 'question_response.dart';

/// Core Interview entity representing a complete interview session
class Interview extends Equatable {
  /// Unique identifier for the interview
  final String id;

  /// Name of the candidate being interviewed
  final String candidateName;

  /// Role the candidate is applying for
  final Role role;

  /// Experience level of the candidate
  final Level level;

  /// When the interview started
  final DateTime startTime;

  /// When the interview ended (null if still in progress)
  final DateTime? endTime;

  /// List of responses to interview questions
  final List<QuestionResponse> responses;

  /// Current status of the interview
  final InterviewStatus status;

  /// Overall score calculated from responses (null if not calculated)
  final double? overallScore;

  /// Technical score from question responses (0-100)
  final double? technicalScore;

  /// Soft skills score from evaluation (0-100)
  final double? softSkillsScore;

  /// Current question index (for tracking progress)
  final int currentQuestionIndex;

  /// Total number of questions in the interview
  final int totalQuestions;

  const Interview({
    required this.id,
    required this.candidateName,
    required this.role,
    required this.level,
    required this.startTime,
    this.endTime,
    required this.responses,
    required this.status,
    this.overallScore,
    this.technicalScore,
    this.softSkillsScore,
    this.currentQuestionIndex = 0,
    this.totalQuestions = 25,
  });

  /// Creates a copy of this interview with updated fields
  Interview copyWith({
    String? id,
    String? candidateName,
    Role? role,
    Level? level,
    DateTime? startTime,
    DateTime? endTime,
    List<QuestionResponse>? responses,
    InterviewStatus? status,
    double? overallScore,
    double? technicalScore,
    double? softSkillsScore,
    int? currentQuestionIndex,
    int? totalQuestions,
  }) {
    return Interview(
      id: id ?? this.id,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      level: level ?? this.level,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      responses: responses ?? this.responses,
      status: status ?? this.status,
      overallScore: overallScore ?? this.overallScore,
      technicalScore: technicalScore ?? this.technicalScore,
      softSkillsScore: softSkillsScore ?? this.softSkillsScore,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
    );
  }

  /// Calculates the completion percentage of the interview
  double get completionPercentage {
    if (totalQuestions == 0) return 0.0;
    return (responses.length / totalQuestions) * 100.0;
  }

  /// Gets the duration of the interview
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  /// Checks if the interview is completed
  bool get isCompleted => status == InterviewStatus.completed;

  /// Checks if the interview is in progress
  bool get isInProgress => status == InterviewStatus.inProgress;

  /// Calculate technical score from question responses
  /// Uses weighted scoring: 50% Programming, 25% Soft Skills, 25% System Design
  double calculateTechnicalScore() {
    if (responses.isEmpty) return 0.0;

    // Group responses by category
    final programmingResponses = <QuestionResponse>[];
    final softSkillsResponses = <QuestionResponse>[];
    final systemDesignResponses = <QuestionResponse>[];
    final otherResponses = <QuestionResponse>[];

    for (final response in responses) {
      final category = response.questionCategory?.toLowerCase() ?? '';

      if (category.contains('programming') ||
          category.contains('coding') ||
          category.contains('algorithm') ||
          category.contains('data structure')) {
        programmingResponses.add(response);
      } else if (category.contains('soft') ||
          category.contains('communication') ||
          category.contains('behavioral')) {
        softSkillsResponses.add(response);
      } else if (category.contains('system') ||
          category.contains('design') ||
          category.contains('architecture')) {
        systemDesignResponses.add(response);
      } else {
        otherResponses.add(response);
      }
    }

    // Calculate category scores (percentage of correct answers)
    double programmingScore = _calculateCategoryScore(programmingResponses);
    double softSkillsScore = _calculateCategoryScore(softSkillsResponses);
    double systemDesignScore = _calculateCategoryScore(systemDesignResponses);
    double otherScore = _calculateCategoryScore(otherResponses);

    // If no questions in specific categories, distribute to "other"
    if (programmingResponses.isEmpty &&
        softSkillsResponses.isEmpty &&
        systemDesignResponses.isEmpty) {
      return otherScore;
    }

    // Apply weighted scoring: 50% Programming, 25% Soft Skills, 25% System Design
    double weightedScore = 0.0;
    double totalWeight = 0.0;

    if (programmingResponses.isNotEmpty) {
      weightedScore += programmingScore * 0.5;
      totalWeight += 0.5;
    }

    if (softSkillsResponses.isNotEmpty) {
      weightedScore += softSkillsScore * 0.25;
      totalWeight += 0.25;
    }

    if (systemDesignResponses.isNotEmpty) {
      weightedScore += systemDesignScore * 0.25;
      totalWeight += 0.25;
    }

    // If some categories are missing, redistribute weight to others
    if (totalWeight < 1.0 && otherResponses.isNotEmpty) {
      weightedScore += otherScore * (1.0 - totalWeight);
    } else if (totalWeight > 0) {
      weightedScore = weightedScore / totalWeight;
    }

    return weightedScore.clamp(0.0, 100.0);
  }

  /// Calculate category performance scores
  Map<String, double> calculateCategoryPerformance() {
    if (responses.isEmpty) {
      return {'Programming': 0.0, 'Soft Skills': 0.0, 'System Design': 0.0};
    }

    // Group responses by category
    final programmingResponses = <QuestionResponse>[];
    final softSkillsResponses = <QuestionResponse>[];
    final systemDesignResponses = <QuestionResponse>[];

    for (final response in responses) {
      final category = response.questionCategory?.toLowerCase() ?? '';

      if (category.contains('programming') ||
          category.contains('coding') ||
          category.contains('algorithm') ||
          category.contains('data structure')) {
        programmingResponses.add(response);
      } else if (category.contains('soft') ||
          category.contains('communication') ||
          category.contains('behavioral')) {
        softSkillsResponses.add(response);
      } else if (category.contains('system') ||
          category.contains('design') ||
          category.contains('architecture')) {
        systemDesignResponses.add(response);
      } else {
        // Default to programming for uncategorized questions
        programmingResponses.add(response);
      }
    }

    return {
      'Programming': _calculateCategoryScore(programmingResponses),
      'Soft Skills': _calculateCategoryScore(softSkillsResponses),
      'System Design': _calculateCategoryScore(systemDesignResponses),
    };
  }

  /// Helper method to calculate score for a category
  double _calculateCategoryScore(List<QuestionResponse> categoryResponses) {
    if (categoryResponses.isEmpty) return 0.0;

    final correctCount = categoryResponses.where((r) => r.isCorrect).length;
    return (correctCount / categoryResponses.length) * 100.0;
  }

  /// Calculate final overall score combining technical (70%) and soft skills (30%)
  double calculateOverallScore({double? evaluationScore}) {
    final techScore = technicalScore ?? calculateTechnicalScore();

    if (evaluationScore != null) {
      // 70% technical + 30% soft skills evaluation
      return (techScore * 0.7) + (evaluationScore * 0.3);
    }

    // If no evaluation score, use technical score only
    return techScore;
  }

  /// Get recommendation based on overall score
  String getRecommendation({double? evaluationScore}) {
    final score = calculateOverallScore(evaluationScore: evaluationScore);

    if (score >= 70.0) {
      return 'Recommended for Hire';
    } else {
      return 'Not Recommended';
    }
  }

  /// Get detailed performance stats
  Map<String, dynamic> getPerformanceStats() {
    final categoryPerformance = calculateCategoryPerformance();
    final correctAnswers = responses.where((r) => r.isCorrect).length;
    final totalAnswered = responses.length;

    return {
      'totalQuestions': totalQuestions,
      'answeredQuestions': totalAnswered,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': totalAnswered - correctAnswers,
      'completionPercentage': completionPercentage,
      'technicalScore': technicalScore ?? calculateTechnicalScore(),
      'categoryPerformance': categoryPerformance,
      'duration': duration?.inMinutes ?? 0,
    };
  }

  /// Creates an Interview from JSON data
  factory Interview.fromJson(Map<String, dynamic> json) {
    return Interview(
      id: json['id'] ?? '',
      candidateName: json['candidateName'] ?? '',
      role: _parseRole(json['role']),
      level: _parseLevel(json['level']),
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'])
          : null,
      responses: (json['responses'] as List<dynamic>? ?? [])
          .map((r) => QuestionResponse.fromJson(r))
          .toList(),
      status: _parseInterviewStatus(json['status']),
      overallScore: json['overallScore']?.toDouble(),
      technicalScore: json['technicalScore']?.toDouble(),
      softSkillsScore: json['softSkillsScore']?.toDouble(),
      currentQuestionIndex: json['currentQuestionIndex'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 25,
    );
  }

  /// Converts this Interview to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'candidateName': candidateName,
      'role': role.toString(),
      'level': level.toString(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'responses': responses.map((r) => r.toJson()).toList(),
      'status': status.toString(),
      'overallScore': overallScore,
      'technicalScore': technicalScore,
      'softSkillsScore': softSkillsScore,
      'currentQuestionIndex': currentQuestionIndex,
      'totalQuestions': totalQuestions,
    };
  }

  /// Helper method to parse Role from string
  static Role _parseRole(dynamic roleValue) {
    if (roleValue == null) return Role.flutter;

    final roleStr = roleValue.toString().toLowerCase();
    for (final role in Role.values) {
      if (role.toString().toLowerCase().contains(roleStr) ||
          roleStr.contains(role.toString().toLowerCase())) {
        return role;
      }
    }
    return Role.flutter; // Default fallback
  }

  /// Helper method to parse Level from string
  static Level _parseLevel(dynamic levelValue) {
    if (levelValue == null) return Level.associate;

    final levelStr = levelValue.toString().toLowerCase();
    for (final level in Level.values) {
      if (level.toString().toLowerCase().contains(levelStr) ||
          levelStr.contains(level.toString().toLowerCase())) {
        return level;
      }
    }
    return Level.associate; // Default fallback
  }

  /// Helper method to parse InterviewStatus from string
  static InterviewStatus _parseInterviewStatus(dynamic statusValue) {
    if (statusValue == null) return InterviewStatus.inProgress;

    final statusStr = statusValue.toString().toLowerCase();
    for (final status in InterviewStatus.values) {
      if (status.toString().toLowerCase().contains(statusStr) ||
          statusStr.contains(status.toString().toLowerCase())) {
        return status;
      }
    }
    return InterviewStatus.inProgress; // Default fallback
  }

  @override
  List<Object?> get props => [
    id,
    candidateName,
    role,
    level,
    startTime,
    endTime,
    responses,
    status,
    overallScore,
    technicalScore,
    softSkillsScore,
    currentQuestionIndex,
    totalQuestions,
  ];

  @override
  String toString() {
    return 'Interview(id: $id, candidateName: $candidateName, role: $role, '
        'level: $level, status: $status, responses: ${responses.length})';
  }
}
