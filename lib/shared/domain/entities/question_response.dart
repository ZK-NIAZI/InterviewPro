import 'package:equatable/equatable.dart';

/// Entity representing a response to an interview question
class QuestionResponse extends Equatable {
  /// ID of the question this response is for
  final String questionId;

  /// The actual question text (for reference)
  final String questionText;

  /// Category of the question (for performance calculation)
  final String? questionCategory;

  /// Difficulty level of the question
  final String? questionDifficulty;

  /// Whether the candidate answered correctly (Yes/No marking)
  final bool isCorrect;

  /// Optional notes from the interviewer about the response
  final String? notes;

  /// When this response was recorded
  final DateTime timestamp;

  /// Time taken to answer the question (in seconds)
  final int? responseTimeSeconds;

  const QuestionResponse({
    required this.questionId,
    required this.questionText,
    this.questionCategory,
    this.questionDifficulty,
    required this.isCorrect,
    this.notes,
    required this.timestamp,
    this.responseTimeSeconds,
  });

  /// Creates a copy of this response with updated fields
  QuestionResponse copyWith({
    String? questionId,
    String? questionText,
    String? questionCategory,
    String? questionDifficulty,
    bool? isCorrect,
    String? notes,
    DateTime? timestamp,
    int? responseTimeSeconds,
  }) {
    return QuestionResponse(
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      questionCategory: questionCategory ?? this.questionCategory,
      questionDifficulty: questionDifficulty ?? this.questionDifficulty,
      isCorrect: isCorrect ?? this.isCorrect,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
      responseTimeSeconds: responseTimeSeconds ?? this.responseTimeSeconds,
    );
  }

  /// Checks if this response has notes
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Gets a display-friendly result text
  String get resultText => isCorrect ? 'Correct' : 'Incorrect';

  /// Gets response time in a human-readable format
  String get responseTimeText {
    if (responseTimeSeconds == null) return 'Unknown';

    final minutes = responseTimeSeconds! ~/ 60;
    final seconds = responseTimeSeconds! % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Gets a summary of the response for display
  String get summary {
    final result = resultText;
    if (hasNotes) {
      final notePreview = notes!.length > 50
          ? '${notes!.substring(0, 50)}...'
          : notes!;
      return '$result - $notePreview';
    }
    return result;
  }

  /// Creates a QuestionResponse from an interview question and user input
  factory QuestionResponse.fromQuestion({
    required String questionId,
    required String questionText,
    String? questionCategory,
    String? questionDifficulty,
    required bool isCorrect,
    String? notes,
    int? responseTimeSeconds,
  }) {
    return QuestionResponse(
      questionId: questionId,
      questionText: questionText,
      questionCategory: questionCategory,
      questionDifficulty: questionDifficulty,
      isCorrect: isCorrect,
      notes: notes,
      timestamp: DateTime.now(),
      responseTimeSeconds: responseTimeSeconds,
    );
  }

  /// Creates a QuestionResponse from JSON data
  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      questionId: json['questionId'] ?? '',
      questionText: json['questionText'] ?? '',
      questionCategory: json['questionCategory'],
      questionDifficulty: json['questionDifficulty'],
      isCorrect: json['isCorrect'] ?? false,
      notes: json['notes'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      responseTimeSeconds: json['responseTimeSeconds'],
    );
  }

  /// Converts this QuestionResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'questionCategory': questionCategory,
      'questionDifficulty': questionDifficulty,
      'isCorrect': isCorrect,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'responseTimeSeconds': responseTimeSeconds,
    };
  }

  @override
  List<Object?> get props => [
    questionId,
    questionText,
    questionCategory,
    questionDifficulty,
    isCorrect,
    notes,
    timestamp,
    responseTimeSeconds,
  ];

  @override
  String toString() {
    return 'QuestionResponse(questionId: $questionId, questionText: ${questionText.length > 50 ? '${questionText.substring(0, 50)}...' : questionText}, '
        'category: $questionCategory, isCorrect: $isCorrect, hasNotes: $hasNotes, timestamp: $timestamp)';
  }
}
