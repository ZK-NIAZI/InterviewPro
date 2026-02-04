import 'package:flutter/foundation.dart';
import '../../shared/domain/entities/entities.dart';
import '../../shared/domain/repositories/interview_repository.dart';
import 'cache_manager.dart';

/// Service for managing interview sessions and real-time response tracking
class InterviewSessionManager extends ChangeNotifier {
  final InterviewRepository _interviewRepository;

  // Current session state
  Interview? _currentInterview;
  List<InterviewQuestion> _sessionQuestions = [];
  DateTime? _questionStartTime;

  // Cache keys
  static const String _currentInterviewKey = 'current_interview_session';
  static const String _sessionQuestionsKey = 'session_questions';

  InterviewSessionManager(this._interviewRepository);

  // Getters
  Interview? get currentInterview => _currentInterview;
  List<InterviewQuestion> get sessionQuestions => _sessionQuestions;
  bool get hasActiveSession => _currentInterview != null;
  int get currentQuestionIndex => _currentInterview?.currentQuestionIndex ?? 0;
  int get totalQuestions => _currentInterview?.totalQuestions ?? 0;
  double get progressPercentage =>
      totalQuestions > 0 ? (currentQuestionIndex / totalQuestions) * 100 : 0.0;

  /// Start a new interview session
  Future<Interview> startInterview({
    required String candidateName,
    required String role,
    required String level,
    required List<InterviewQuestion> questions,
  }) async {
    try {
      // Create new interview entity
      final interview = Interview(
        id: 'interview_${DateTime.now().millisecondsSinceEpoch}',
        candidateName: candidateName,
        role: _parseRole(role),
        level: _parseLevel(level),
        startTime: DateTime.now(),
        responses: [],
        status: InterviewStatus.inProgress,
        currentQuestionIndex: 0,
        totalQuestions: questions.length,
      );

      // Set current session
      _currentInterview = interview;
      _sessionQuestions = questions;
      _questionStartTime = DateTime.now();

      // Cache the session data
      _cacheSessionData();

      // Save to repository
      await _interviewRepository.saveInterview(interview);

      debugPrint('✅ Started interview session: ${interview.id}');
      notifyListeners();

      return interview;
    } catch (e) {
      debugPrint('❌ Error starting interview session: $e');
      rethrow;
    }
  }

  /// Record a response to the current question
  Future<void> recordResponse({required bool isCorrect, String? notes}) async {
    if (_currentInterview == null || _sessionQuestions.isEmpty) {
      throw Exception('No active interview session');
    }

    if (currentQuestionIndex >= _sessionQuestions.length) {
      throw Exception('No more questions available');
    }

    try {
      final currentQuestion = _sessionQuestions[currentQuestionIndex];
      final responseTime = _questionStartTime != null
          ? DateTime.now().difference(_questionStartTime!).inSeconds
          : null;

      // Create question response
      final response = QuestionResponse.fromQuestion(
        questionId: currentQuestion.id,
        questionText: currentQuestion.question,
        questionCategory: currentQuestion.categoryDisplayName,
        questionDifficulty: currentQuestion.difficulty,
        isCorrect: isCorrect,
        notes: notes,
        responseTimeSeconds: responseTime,
      );

      // Add response to current interview
      final updatedResponses = [..._currentInterview!.responses, response];

      // Calculate updated technical score
      final updatedTechnicalScore = _calculateTechnicalScore(updatedResponses);

      // Update interview
      _currentInterview = _currentInterview!.copyWith(
        responses: updatedResponses,
        technicalScore: updatedTechnicalScore,
      );

      // Cache updated session
      _cacheSessionData();

      // Save to repository
      await _interviewRepository.updateInterview(_currentInterview!);

      debugPrint(
        '✅ Recorded response for question ${currentQuestionIndex + 1}',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error recording response: $e');
      rethrow;
    }
  }

  /// Move to the next question
  Future<void> nextQuestion() async {
    if (_currentInterview == null) {
      throw Exception('No active interview session');
    }

    if (currentQuestionIndex >= totalQuestions - 1) {
      throw Exception('Already at the last question');
    }

    try {
      // Update question index
      _currentInterview = _currentInterview!.copyWith(
        currentQuestionIndex: currentQuestionIndex + 1,
      );

      // Reset question start time
      _questionStartTime = DateTime.now();

      // Cache updated session
      _cacheSessionData();

      // Save to repository
      await _interviewRepository.updateInterview(_currentInterview!);

      debugPrint('✅ Moved to question ${currentQuestionIndex + 1}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error moving to next question: $e');
      rethrow;
    }
  }

  /// Move to the previous question
  Future<void> previousQuestion() async {
    if (_currentInterview == null) {
      throw Exception('No active interview session');
    }

    if (currentQuestionIndex <= 0) {
      throw Exception('Already at the first question');
    }

    try {
      // Update question index
      _currentInterview = _currentInterview!.copyWith(
        currentQuestionIndex: currentQuestionIndex - 1,
      );

      // Reset question start time
      _questionStartTime = DateTime.now();

      // Cache updated session
      _cacheSessionData();

      // Save to repository
      await _interviewRepository.updateInterview(_currentInterview!);

      debugPrint('✅ Moved to question ${currentQuestionIndex + 1}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error moving to previous question: $e');
      rethrow;
    }
  }

  /// Complete the interview session
  Future<Interview> completeInterview() async {
    if (_currentInterview == null) {
      throw Exception('No active interview session');
    }

    try {
      // Calculate final technical score
      final finalTechnicalScore = _currentInterview!.calculateTechnicalScore();

      // Update interview status
      _currentInterview = _currentInterview!.copyWith(
        status: InterviewStatus.completed,
        endTime: DateTime.now(),
        technicalScore: finalTechnicalScore,
      );

      // Save to repository
      await _interviewRepository.updateInterview(_currentInterview!);

      // Clear session cache
      _clearSessionCache();

      debugPrint('✅ Completed interview session: ${_currentInterview!.id}');

      final completedInterview = _currentInterview!;

      // Clear current session
      _currentInterview = null;
      _sessionQuestions = [];
      _questionStartTime = null;

      notifyListeners();

      return completedInterview;
    } catch (e) {
      debugPrint('❌ Error completing interview: $e');
      rethrow;
    }
  }

  /// Get current question
  InterviewQuestion? getCurrentQuestion() {
    if (_sessionQuestions.isEmpty ||
        currentQuestionIndex >= _sessionQuestions.length) {
      return null;
    }
    return _sessionQuestions[currentQuestionIndex];
  }

  /// Get response for a specific question index
  QuestionResponse? getResponseForQuestion(int questionIndex) {
    if (_currentInterview == null ||
        questionIndex >= _sessionQuestions.length) {
      return null;
    }

    final questionId = _sessionQuestions[questionIndex].id;
    return _currentInterview!.responses
        .where((response) => response.questionId == questionId)
        .firstOrNull;
  }

  /// Check if current question has been answered
  bool get isCurrentQuestionAnswered {
    return getResponseForQuestion(currentQuestionIndex) != null;
  }

  /// Get real-time performance stats
  Map<String, dynamic> getPerformanceStats() {
    if (_currentInterview == null) {
      return {
        'totalQuestions': 0,
        'answeredQuestions': 0,
        'correctAnswers': 0,
        'incorrectAnswers': 0,
        'completionPercentage': 0.0,
        'technicalScore': 0.0,
        'categoryPerformance': <String, double>{},
      };
    }

    return _currentInterview!.getPerformanceStats();
  }

  /// Resume an existing interview session
  Future<void> resumeInterview(String interviewId) async {
    try {
      final interview = await _interviewRepository.getInterviewById(
        interviewId,
      );
      if (interview == null) {
        throw Exception('Interview not found: $interviewId');
      }

      if (interview.status != InterviewStatus.inProgress) {
        throw Exception('Interview is not in progress');
      }

      _currentInterview = interview;
      _questionStartTime = DateTime.now();

      // Try to load session questions from cache
      final cachedQuestions = CacheManager.get<List<InterviewQuestion>>(
        _sessionQuestionsKey,
      );
      if (cachedQuestions != null) {
        _sessionQuestions = cachedQuestions;
      }

      debugPrint('✅ Resumed interview session: $interviewId');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error resuming interview: $e');
      rethrow;
    }
  }

  /// Load session from cache (for app restart recovery)
  Future<void> loadSessionFromCache() async {
    try {
      final cachedInterview = CacheManager.get<Interview>(_currentInterviewKey);
      final cachedQuestions = CacheManager.get<List<InterviewQuestion>>(
        _sessionQuestionsKey,
      );

      if (cachedInterview != null && cachedQuestions != null) {
        _currentInterview = cachedInterview;
        _sessionQuestions = cachedQuestions;
        _questionStartTime = DateTime.now();

        debugPrint(
          '✅ Loaded interview session from cache: ${cachedInterview.id}',
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error loading session from cache: $e');
    }
  }

  /// Clear current session
  void clearSession() {
    _currentInterview = null;
    _sessionQuestions = [];
    _questionStartTime = null;
    _clearSessionCache();
    notifyListeners();
  }

  /// Helper method to calculate technical score
  double _calculateTechnicalScore(List<QuestionResponse> responses) {
    if (responses.isEmpty) return 0.0;

    // Use the Interview entity's calculation method
    final tempInterview = Interview(
      id: 'temp',
      candidateName: 'temp',
      role: Role.flutter,
      level: Level.associate,
      startTime: DateTime.now(),
      responses: responses,
      status: InterviewStatus.inProgress,
    );

    return tempInterview.calculateTechnicalScore();
  }

  /// Cache session data
  void _cacheSessionData() {
    if (_currentInterview != null) {
      CacheManager.set(
        _currentInterviewKey,
        _currentInterview!,
        const Duration(hours: 24),
      );
    }
    if (_sessionQuestions.isNotEmpty) {
      CacheManager.set(
        _sessionQuestionsKey,
        _sessionQuestions,
        const Duration(hours: 24),
      );
    }
  }

  /// Clear session cache
  void _clearSessionCache() {
    CacheManager.remove(_currentInterviewKey);
    CacheManager.remove(_sessionQuestionsKey);
  }

  /// Parse role string to Role enum
  Role _parseRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'flutter developer':
        return Role.flutter;
      case 'backend developer':
        return Role.backend;
      case 'frontend developer':
        return Role.frontend;
      case 'full stack developer':
        return Role.fullStack;
      case 'mobile developer':
        return Role.mobile;
      default:
        return Role.flutter;
    }
  }

  /// Parse level string to Level enum
  Level _parseLevel(String levelString) {
    switch (levelString.toLowerCase()) {
      case 'intern':
        return Level.intern;
      case 'associate':
        return Level.associate;
      case 'senior':
        return Level.senior;
      default:
        return Level.associate;
    }
  }

  @override
  void dispose() {
    // Save current session to cache before disposing
    if (_currentInterview != null) {
      _cacheSessionData();
    }
    super.dispose();
  }
}

/// Extension to add firstOrNull method for older Dart versions
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
