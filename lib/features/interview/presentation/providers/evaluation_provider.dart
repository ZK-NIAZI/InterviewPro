import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../shared/domain/entities/entities.dart';
import '../../../../shared/domain/repositories/repositories.dart';

/// Provider for managing evaluation state and data
class EvaluationProvider extends ChangeNotifier {
  final InterviewRepository _interviewRepository;

  EvaluationProvider(this._interviewRepository);

  // Evaluation form state
  int _communicationSkills = 0;
  int _problemSolvingApproach = 0;
  int _culturalFit = 0;
  int _overallImpression = 0;
  String _additionalComments = '';
  bool _isLoading = false;
  bool _isSaving = false;

  // Getters
  int get communicationSkills => _communicationSkills;
  int get problemSolvingApproach => _problemSolvingApproach;
  int get culturalFit => _culturalFit;
  int get overallImpression => _overallImpression;
  String get additionalComments => _additionalComments;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  /// Calculate overall score based on current ratings
  double get calculatedScore {
    return Evaluation.calculateScore(
      communicationSkills: _communicationSkills,
      problemSolvingApproach: _problemSolvingApproach,
      culturalFit: _culturalFit,
      overallImpression: _overallImpression,
    );
  }

  /// Check if evaluation form is valid
  bool get isFormValid {
    return _communicationSkills > 0 &&
        _problemSolvingApproach > 0 &&
        _culturalFit > 0 &&
        _overallImpression > 0;
  }

  /// Update communication skills rating
  void updateCommunicationSkills(int rating) {
    _communicationSkills = rating;
    notifyListeners();
  }

  /// Update problem solving approach rating
  void updateProblemSolvingApproach(int rating) {
    _problemSolvingApproach = rating;
    notifyListeners();
  }

  /// Update cultural fit rating
  void updateCulturalFit(int rating) {
    _culturalFit = rating;
    notifyListeners();
  }

  /// Update overall impression rating
  void updateOverallImpression(int rating) {
    _overallImpression = rating;
    notifyListeners();
  }

  /// Update additional comments
  void updateAdditionalComments(String comments) {
    _additionalComments = comments;
    notifyListeners();
  }

  /// Reset evaluation form
  void resetForm() {
    _communicationSkills = 0;
    _problemSolvingApproach = 0;
    _culturalFit = 0;
    _overallImpression = 0;
    _additionalComments = '';
    notifyListeners();
  }

  /// Load existing evaluation for an interview
  Future<void> loadEvaluation(String interviewId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real implementation, this would load from repository
      // For now, we'll just reset the form
      resetForm();
    } catch (e) {
      debugPrint('Error loading evaluation: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save evaluation
  Future<bool> saveEvaluation({
    required String interviewId,
    required String candidateName,
    required String role,
    required String level,
  }) async {
    if (!isFormValid) {
      return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final evaluation = Evaluation.create(
        interviewId: interviewId,
        candidateName: candidateName,
        role: role,
        level: level,
        communicationSkills: _communicationSkills,
        problemSolvingApproach: _problemSolvingApproach,
        culturalFit: _culturalFit,
        overallImpression: _overallImpression,
        additionalComments: _additionalComments,
      );

      // In a real implementation, this would save to repository
      // For now, we'll simulate a successful save
      await Future.delayed(const Duration(seconds: 1));

      // Update the interview with the calculated score
      final interview = await _interviewRepository.getInterviewById(
        interviewId,
      );
      if (interview != null) {
        final updatedInterview = interview.copyWith(
          status: InterviewStatus.completed,
          overallScore: evaluation.calculatedScore,
          endTime: DateTime.now(),
        );
        await _interviewRepository.updateInterview(updatedInterview);
      }

      return true;
    } catch (e) {
      debugPrint('Error saving evaluation: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Generate evaluation report
  Future<String> generateReport({
    required String candidateName,
    required String role,
    required String level,
  }) async {
    final score = calculatedScore;
    final scorePercentage = (score * 10).toInt();

    final report =
        '''
CANDIDATE EVALUATION REPORT

Candidate: $candidateName
Role: $role
Level: $level
Date: ${DateTime.now().toString().split(' ')[0]}

EVALUATION SCORES:
• Communication Skills: $_communicationSkills/5
• Problem-Solving Approach: $_problemSolvingApproach/5
• Cultural Fit: $_culturalFit/5
• Overall Impression: $_overallImpression/5

OVERALL SCORE: ${score.toStringAsFixed(1)}/10 ($scorePercentage%)

ADDITIONAL COMMENTS:
${_additionalComments.isEmpty ? 'No additional comments provided.' : _additionalComments}

RECOMMENDATION:
${_getRecommendation(score)}
''';

    return report;
  }

  /// Get recommendation based on score
  String _getRecommendation(double score) {
    if (score >= 8.0) {
      return 'Highly Recommended - Excellent candidate with strong skills across all areas.';
    } else if (score >= 6.0) {
      return 'Recommended - Good candidate with solid skills, minor areas for improvement.';
    } else if (score >= 4.0) {
      return 'Consider with Reservations - Average candidate, significant areas need improvement.';
    } else {
      return 'Not Recommended - Candidate needs substantial development before being suitable for this role.';
    }
  }
}
