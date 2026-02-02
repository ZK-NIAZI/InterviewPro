import 'package:hive/hive.dart';
import '../../domain/entities/entities.dart';

part 'evaluation_model.g.dart';

/// Hive model for evaluation data persistence
@HiveType(typeId: 4)
class EvaluationModel extends HiveObject {
  @HiveField(0)
  final String interviewId;

  @HiveField(1)
  final String candidateName;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final String level;

  @HiveField(4)
  final DateTime evaluationDate;

  @HiveField(5)
  final int communicationSkills;

  @HiveField(6)
  final int problemSolvingApproach;

  @HiveField(7)
  final int culturalFit;

  @HiveField(8)
  final int overallImpression;

  @HiveField(9)
  final String additionalComments;

  @HiveField(10)
  final double calculatedScore;

  EvaluationModel({
    required this.interviewId,
    required this.candidateName,
    required this.role,
    required this.level,
    required this.evaluationDate,
    required this.communicationSkills,
    required this.problemSolvingApproach,
    required this.culturalFit,
    required this.overallImpression,
    required this.additionalComments,
    required this.calculatedScore,
  });

  /// Convert from domain entity to data model
  factory EvaluationModel.fromEntity(Evaluation evaluation) {
    return EvaluationModel(
      interviewId: evaluation.interviewId,
      candidateName: evaluation.candidateName,
      role: evaluation.role,
      level: evaluation.level,
      evaluationDate: evaluation.evaluationDate,
      communicationSkills: evaluation.communicationSkills,
      problemSolvingApproach: evaluation.problemSolvingApproach,
      culturalFit: evaluation.culturalFit,
      overallImpression: evaluation.overallImpression,
      additionalComments: evaluation.additionalComments,
      calculatedScore: evaluation.calculatedScore,
    );
  }

  /// Convert from data model to domain entity
  Evaluation toEntity() {
    return Evaluation(
      interviewId: interviewId,
      candidateName: candidateName,
      role: role,
      level: level,
      evaluationDate: evaluationDate,
      communicationSkills: communicationSkills,
      problemSolvingApproach: problemSolvingApproach,
      culturalFit: culturalFit,
      overallImpression: overallImpression,
      additionalComments: additionalComments,
      calculatedScore: calculatedScore,
    );
  }
}
