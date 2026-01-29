import 'package:hive/hive.dart';
import '../../domain/entities/entities.dart';

part 'question_response_model.g.dart';

/// Hive model for QuestionResponse entity
@HiveType(typeId: 2)
class QuestionResponseModel extends HiveObject {
  @HiveField(0)
  String questionId;

  @HiveField(1)
  bool isCorrect;

  @HiveField(2)
  String? notes;

  @HiveField(3)
  DateTime timestamp;

  QuestionResponseModel({
    required this.questionId,
    required this.isCorrect,
    this.notes,
    required this.timestamp,
  });

  /// Converts from domain entity to model
  factory QuestionResponseModel.fromEntity(QuestionResponse response) {
    return QuestionResponseModel(
      questionId: response.questionId,
      isCorrect: response.isCorrect,
      notes: response.notes,
      timestamp: response.timestamp,
    );
  }

  /// Converts from model to domain entity
  QuestionResponse toEntity() {
    return QuestionResponse(
      questionId: questionId,
      isCorrect: isCorrect,
      notes: notes,
      timestamp: timestamp,
    );
  }
}
