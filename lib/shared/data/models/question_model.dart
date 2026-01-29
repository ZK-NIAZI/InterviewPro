import 'package:hive/hive.dart';
import '../../domain/entities/entities.dart';

part 'question_model.g.dart';

/// Hive model for Question entity
@HiveType(typeId: 1)
class QuestionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  QuestionCategory category;

  @HiveField(3)
  List<Role> applicableRoles;

  @HiveField(4)
  Level difficulty;

  @HiveField(5)
  String? expectedAnswer;

  @HiveField(6)
  List<String> tags;

  QuestionModel({
    required this.id,
    required this.text,
    required this.category,
    required this.applicableRoles,
    required this.difficulty,
    this.expectedAnswer,
    required this.tags,
  });

  /// Converts from domain entity to model
  factory QuestionModel.fromEntity(Question question) {
    return QuestionModel(
      id: question.id,
      text: question.text,
      category: question.category,
      applicableRoles: question.applicableRoles,
      difficulty: question.difficulty,
      expectedAnswer: question.expectedAnswer,
      tags: question.tags,
    );
  }

  /// Converts from model to domain entity
  Question toEntity() {
    return Question(
      id: id,
      text: text,
      category: category,
      applicableRoles: applicableRoles,
      difficulty: difficulty,
      expectedAnswer: expectedAnswer,
      tags: tags,
    );
  }
}
