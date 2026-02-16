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

  /// The specific name of the role (supports custom roles)
  final String roleName;

  /// Experience level of the candidate
  final Level level;

  /// When the interview started
  final DateTime startTime;

  /// When the interview ended (null if still in progress)
  final DateTime? endTime;

  /// Timestamp of last modification for sync
  final DateTime lastModified;

  /// List of responses to interview questions
  final List<QuestionResponse> responses;

  /// Current status of the interview
  final InterviewStatus status;

  /// Overall score calculated from responses (null if not calculated)
  final double? overallScore;

  // technicalScore is now a dynamic getter, not a stored field
  // final double? technicalScore;

  /// Soft skills score from evaluation (0-100)
  final double? softSkillsScore;

  /// Current question index (for tracking progress)
  final int currentQuestionIndex;

  /// Total number of questions in the interview
  final int totalQuestions;

  /// Communication skills rating (0-5)
  final int communicationSkills;

  /// Problem solving approach rating (0-5)
  final int problemSolvingApproach;

  /// Cultural fit rating (0-5)
  final int culturalFit;

  /// Overall impression rating (0-5)
  final int overallImpression;

  /// Additional comments/notes from interviewer
  final String additionalComments;

  /// Path to the interview-wide voice recording
  final String? voiceRecordingPath;

  /// Total duration of the interview voice recording
  final int? voiceRecordingDurationSeconds;

  /// Full transcript of the interview voice recording
  final String? transcript;

  const Interview({
    required this.id,
    required this.candidateName,
    required this.role,
    this.roleName = '',
    required this.level,
    required this.startTime,
    this.endTime,
    required this.lastModified,
    required this.responses,
    required this.status,
    this.overallScore,
    // technicalScore is calculated dynamically
    this.softSkillsScore,
    this.communicationSkills = 0,
    this.problemSolvingApproach = 0,
    this.culturalFit = 0,
    this.overallImpression = 0,
    this.additionalComments = '',
    this.currentQuestionIndex = 0,
    this.totalQuestions = 25,
    this.voiceRecordingPath,
    this.voiceRecordingDurationSeconds,
    this.transcript,
  });

  /// Creates a copy of this interview with updated fields
  Interview copyWith({
    String? id,
    String? candidateName,
    Role? role,
    String? roleName,
    Level? level,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? lastModified,
    List<QuestionResponse>? responses,
    InterviewStatus? status,
    double? overallScore,
    // technicalScore removed from copyWith to enforce dynamic calculation
    double? softSkillsScore,
    int? communicationSkills,
    int? problemSolvingApproach,
    int? culturalFit,
    int? overallImpression,
    String? additionalComments,
    int? currentQuestionIndex,
    int? totalQuestions,
    String? voiceRecordingPath,
    int? voiceRecordingDurationSeconds,
    String? transcript,
  }) {
    return Interview(
      id: id ?? this.id,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      roleName: roleName ?? this.roleName,
      level: level ?? this.level,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      lastModified: lastModified ?? DateTime.now(),
      responses: responses ?? this.responses,
      status: status ?? this.status,
      overallScore: overallScore ?? this.overallScore,
      // technicalScore is calculated dynamically
      softSkillsScore: softSkillsScore ?? this.softSkillsScore,
      communicationSkills: communicationSkills ?? this.communicationSkills,
      problemSolvingApproach:
          problemSolvingApproach ?? this.problemSolvingApproach,
      culturalFit: culturalFit ?? this.culturalFit,
      overallImpression: overallImpression ?? this.overallImpression,
      additionalComments: additionalComments ?? this.additionalComments,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      voiceRecordingPath: voiceRecordingPath ?? this.voiceRecordingPath,
      voiceRecordingDurationSeconds:
          voiceRecordingDurationSeconds ?? this.voiceRecordingDurationSeconds,
      transcript: transcript ?? this.transcript,
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

  /// Calculate technical score dynamically from current responses
  /// Formula: (correct answers / total questions answered) * 100
  /// This prevents skewed scores if totalQuestions mismatch actual responses.
  double get technicalScore {
    if (responses.isEmpty) return 0.0;

    // Dynamic denominator: Use actual number of responses to track "current performance"
    // This ensures 1/1 is 100%, 1/2 is 50%, etc.
    final denominator = responses.length;
    final correctAnswers = responses.where((r) => r.isCorrect == true).length;

    return (correctAnswers / denominator) * 100.0;
  }

  /// Calculate final overall score (Alias for technicalScore for now)
  double calculateOverallScore({double? evaluationScore}) {
    // Ignoring evaluationScore for overall percentage as per specific requirement
    return technicalScore;
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
  /// Get detailed performance stats
  Map<String, dynamic> getPerformanceStats() {
    final correctAnswers = responses.where((r) => r.isCorrect).length;
    final totalAnswered = responses.length;

    // Use the actual number of responses as the source of truth for calculations
    // This prevents impossible values like 7/4 or 175% completion
    final actualTotalQuestions =
        (status == InterviewStatus.completed || totalAnswered > totalQuestions)
        ? totalAnswered
        : totalQuestions;

    // Calculate completion percentage based on actual responses
    // If all questions are answered, completion is 100%
    final completion = actualTotalQuestions > 0
        ? (totalAnswered / actualTotalQuestions) * 100.0
        : 0.0;

    return {
      'totalQuestions': actualTotalQuestions,
      'answeredQuestions': totalAnswered,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': totalAnswered - correctAnswers,
      'completionPercentage': completion.clamp(0.0, 100.0),
      'technicalScore': technicalScore,
      'duration': duration?.inMinutes ?? 0,
    };
  }

  /// Creates an Interview from JSON data
  factory Interview.fromJson(Map<String, dynamic> json) {
    return Interview(
      id: json['id'] ?? '',
      candidateName: json['candidateName'] ?? '',
      role: _parseRole(json['role']),
      roleName:
          json['roleName'] ??
          (json['role'] != null
              ? json['role']
                    .toString()
                    .split('.')
                    .last
                    .replaceAllMapped(
                      RegExp(r'([a-z])([A-Z])'),
                      (Match m) => '${m[1]} ${m[2]}',
                    )
              : ''),
      level: _parseLevel(json['level']),
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'])
          : null,
      lastModified: json['lastModified'] != null
          ? DateTime.tryParse(json['lastModified']) ?? DateTime.now()
          : DateTime.now(),
      responses: (json['responses'] as List<dynamic>? ?? [])
          .map((r) => QuestionResponse.fromJson(r))
          .toList(),
      status: _parseInterviewStatus(json['status']),
      overallScore: json['overallScore']?.toDouble(),
      // technicalScore is calculated dynamically from responses
      softSkillsScore: json['softSkillsScore']?.toDouble(),
      communicationSkills: json['communicationSkills'] ?? 0,
      problemSolvingApproach: json['problemSolvingApproach'] ?? 0,
      culturalFit: json['culturalFit'] ?? 0,
      overallImpression: json['overallImpression'] ?? 0,
      additionalComments: json['additionalComments'] ?? '',
      currentQuestionIndex: json['currentQuestionIndex'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 25,
      voiceRecordingPath: json['voiceRecordingPath'],
      voiceRecordingDurationSeconds: json['voiceRecordingDurationSeconds'],
      transcript: json['transcript'],
    );
  }

  /// Converts this Interview to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'candidateName': candidateName,
      'role': role.toString(),
      'roleName': roleName,
      'level': level.toString(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'responses': responses.map((r) => r.toJson()).toList(),
      'status': status.toString(),
      'overallScore': overallScore,
      'technicalScore': technicalScore, // Uses the dynamic getter
      'softSkillsScore': softSkillsScore,
      'communicationSkills': communicationSkills,
      'problemSolvingApproach': problemSolvingApproach,
      'culturalFit': culturalFit,
      'overallImpression': overallImpression,
      'additionalComments': additionalComments,
      'currentQuestionIndex': currentQuestionIndex,
      'totalQuestions': totalQuestions,
      'voiceRecordingPath': voiceRecordingPath,
      'voiceRecordingDurationSeconds': voiceRecordingDurationSeconds,
      'transcript': transcript,
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
    roleName,
    level,
    startTime,
    endTime,
    lastModified,
    responses,
    status,
    overallScore,
    // technicalScore is computed
    softSkillsScore,
    communicationSkills,
    problemSolvingApproach,
    culturalFit,
    overallImpression,
    additionalComments,
    currentQuestionIndex,
    totalQuestions,
    voiceRecordingPath,
    voiceRecordingDurationSeconds,
    transcript,
  ];

  @override
  String toString() {
    return 'Interview(id: $id, candidateName: $candidateName, role: $role, '
        'level: $level, status: $status, responses: ${responses.length})';
  }
}
