import 'package:equatable/equatable.dart';

/// Evaluation entity for candidate assessment
class Evaluation extends Equatable {
  final String interviewId;
  final String candidateName;
  final String role;
  final String level;
  final DateTime evaluationDate;
  final int communicationSkills;
  final int problemSolvingApproach;
  final int culturalFit;
  final int overallImpression;
  final String additionalComments;
  final double calculatedScore;

  const Evaluation({
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

  /// Calculate overall score based on ratings (out of 10)
  static double calculateScore({
    required int communicationSkills,
    required int problemSolvingApproach,
    required int culturalFit,
    required int overallImpression,
  }) {
    final totalRating =
        communicationSkills +
        problemSolvingApproach +
        culturalFit +
        overallImpression;
    return (totalRating / 20.0) * 10.0; // Convert to 0-10 scale
  }

  /// Create evaluation with calculated score
  factory Evaluation.create({
    required String interviewId,
    required String candidateName,
    required String role,
    required String level,
    required int communicationSkills,
    required int problemSolvingApproach,
    required int culturalFit,
    required int overallImpression,
    required String additionalComments,
  }) {
    final calculatedScore = calculateScore(
      communicationSkills: communicationSkills,
      problemSolvingApproach: problemSolvingApproach,
      culturalFit: culturalFit,
      overallImpression: overallImpression,
    );

    return Evaluation(
      interviewId: interviewId,
      candidateName: candidateName,
      role: role,
      level: level,
      evaluationDate: DateTime.now(),
      communicationSkills: communicationSkills,
      problemSolvingApproach: problemSolvingApproach,
      culturalFit: culturalFit,
      overallImpression: overallImpression,
      additionalComments: additionalComments,
      calculatedScore: calculatedScore,
    );
  }

  /// Copy with method for updates
  Evaluation copyWith({
    String? interviewId,
    String? candidateName,
    String? role,
    String? level,
    DateTime? evaluationDate,
    int? communicationSkills,
    int? problemSolvingApproach,
    int? culturalFit,
    int? overallImpression,
    String? additionalComments,
    double? calculatedScore,
  }) {
    return Evaluation(
      interviewId: interviewId ?? this.interviewId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      level: level ?? this.level,
      evaluationDate: evaluationDate ?? this.evaluationDate,
      communicationSkills: communicationSkills ?? this.communicationSkills,
      problemSolvingApproach:
          problemSolvingApproach ?? this.problemSolvingApproach,
      culturalFit: culturalFit ?? this.culturalFit,
      overallImpression: overallImpression ?? this.overallImpression,
      additionalComments: additionalComments ?? this.additionalComments,
      calculatedScore: calculatedScore ?? this.calculatedScore,
    );
  }

  @override
  List<Object?> get props => [
    interviewId,
    candidateName,
    role,
    level,
    evaluationDate,
    communicationSkills,
    problemSolvingApproach,
    culturalFit,
    overallImpression,
    additionalComments,
    calculatedScore,
  ];
}
