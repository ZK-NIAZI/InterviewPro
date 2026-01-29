import 'package:hive/hive.dart';
import '../../domain/entities/entities.dart';
import 'question_response_model.dart';

part 'interview_model.g.dart';

/// Hive model for Interview entity
@HiveType(typeId: 0)
class InterviewModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String candidateName;

  @HiveField(2)
  Role role;

  @HiveField(3)
  Level level;

  @HiveField(4)
  DateTime startTime;

  @HiveField(5)
  DateTime? endTime;

  @HiveField(6)
  List<QuestionResponseModel> responses;

  @HiveField(7)
  InterviewStatus status;

  @HiveField(8)
  double? overallScore;

  InterviewModel({
    required this.id,
    required this.candidateName,
    required this.role,
    required this.level,
    required this.startTime,
    this.endTime,
    required this.responses,
    required this.status,
    this.overallScore,
  });

  /// Converts from domain entity to model
  factory InterviewModel.fromEntity(Interview interview) {
    return InterviewModel(
      id: interview.id,
      candidateName: interview.candidateName,
      role: interview.role,
      level: interview.level,
      startTime: interview.startTime,
      endTime: interview.endTime,
      responses: interview.responses
          .map((response) => QuestionResponseModel.fromEntity(response))
          .toList(),
      status: interview.status,
      overallScore: interview.overallScore,
    );
  }

  /// Converts from model to domain entity
  Interview toEntity() {
    return Interview(
      id: id,
      candidateName: candidateName,
      role: role,
      level: level,
      startTime: startTime,
      endTime: endTime,
      responses: responses.map((response) => response.toEntity()).toList(),
      status: status,
      overallScore: overallScore,
    );
  }
}
