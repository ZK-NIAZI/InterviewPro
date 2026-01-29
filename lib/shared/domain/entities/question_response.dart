import 'package:equatable/equatable.dart';

/// Entity representing a response to an interview question
class QuestionResponse extends Equatable {
  /// ID of the question this response is for
  final String questionId;

  /// Whether the candidate answered correctly (Yes/No marking)
  final bool isCorrect;

  /// Optional notes from the interviewer about the response
  final String? notes;

  /// When this response was recorded
  final DateTime timestamp;

  const QuestionResponse({
    required this.questionId,
    required this.isCorrect,
    this.notes,
    required this.timestamp,
  });

  /// Creates a copy of this response with updated fields
  QuestionResponse copyWith({
    String? questionId,
    bool? isCorrect,
    String? notes,
    DateTime? timestamp,
  }) {
    return QuestionResponse(
      questionId: questionId ?? this.questionId,
      isCorrect: isCorrect ?? this.isCorrect,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Checks if this response has notes
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  /// Gets a display-friendly result text
  String get resultText => isCorrect ? 'Correct' : 'Incorrect';

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

  @override
  List<Object?> get props => [questionId, isCorrect, notes, timestamp];

  @override
  String toString() {
    return 'QuestionResponse(questionId: $questionId, isCorrect: $isCorrect, '
        'hasNotes: $hasNotes, timestamp: $timestamp)';
  }
}
