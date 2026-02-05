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

  /// Start a new interview session with enhanced validation
  Future<Interview> startInterview({
    required String candidateName,
    required String role,
    required String level,
    required List<InterviewQuestion> questions,
  }) async {
    try {
      // Enhanced input validation
      _validateInterviewInput(candidateName, role, level, questions);

      // Create new interview entity with secure ID
      final interview = Interview(
        id: _generateSecureInterviewId(),
        candidateName: _sanitizeInput(candidateName),
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

      // Cache the session data securely
      _cacheSessionData();

      // Save to repository with error handling
      await _interviewRepository.saveInterview(interview);

      debugPrint('✅ Started interview session: ${interview.id}');
      notifyListeners();

      return interview;
    } catch (e) {
      debugPrint('❌ Error starting interview session: $e');
      _clearSession();
      rethrow;
    }
  }

  /// Record a response to the current question with enhanced validation
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

      // Validate and sanitize notes
      final sanitizedNotes = notes != null ? _sanitizeInput(notes) : null;

      // Create question response with validation
      final response = QuestionResponse.fromQuestion(
        questionId: currentQuestion.id,
        questionText: currentQuestion.question,
        questionCategory: currentQuestion.categoryDisplayName,
        questionDifficulty: currentQuestion.difficulty,
        isCorrect: isCorrect,
        notes: sanitizedNotes,
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

      // Save to repository with retry mechanism
      await _saveWithRetry(
        () => _interviewRepository.updateInterview(_currentInterview!),
      );

      debugPrint(
        '✅ Recorded response for question ${currentQuestionIndex + 1}',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error recording response: $e');
      rethrow;
    }
  }

  /// Move to the next question with validation
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

      // Save to repository with retry
      await _saveWithRetry(
        () => _interviewRepository.updateInterview(_currentInterview!),
      );

      debugPrint('✅ Moved to question ${currentQuestionIndex + 1}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error moving to next question: $e');
      rethrow;
    }
  }

  /// Move to the previous question with validation
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

      // Save to repository with retry
      await _saveWithRetry(
        () => _interviewRepository.updateInterview(_currentInterview!),
      );

      debugPrint('✅ Moved to question ${currentQuestionIndex + 1}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error moving to previous question: $e');
      rethrow;
    }
  }

  /// Complete the interview session with enhanced validation
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

      // Save to repository with retry
      await _saveWithRetry(
        () => _interviewRepository.updateInterview(_currentInterview!),
      );

      // Clear session cache
      _clearSessionCache();

      debugPrint('✅ Completed interview session: ${_currentInterview!.id}');

      final completedInterview = _currentInterview!;

      // Clear current session
      _clearSession();

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

  /// Resume an existing interview session with validation
  Future<void> resumeInterview(String interviewId) async {
    try {
      // Validate interview ID
      if (interviewId.isEmpty) {
        throw Exception('Invalid interview ID');
      }

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
    _clearSession();
  }

  /// Private method to clear session
  void _clearSession() {
    _currentInterview = null;
    _sessionQuestions = [];
    _questionStartTime = null;
    _clearSessionCache();
    notifyListeners();
  }

  /// Enhanced input validation
  void _validateInterviewInput(
    String candidateName,
    String role,
    String level,
    List<InterviewQuestion> questions,
  ) {
    if (candidateName.trim().isEmpty) {
      throw Exception('Candidate name cannot be empty');
    }
    if (candidateName.trim().length > 100) {
      throw Exception('Candidate name too long (max 100 characters)');
    }
    if (role.trim().isEmpty) {
      throw Exception('Role cannot be empty');
    }
    if (level.trim().isEmpty) {
      throw Exception('Level cannot be empty');
    }
    if (questions.isEmpty) {
      throw Exception('Questions list cannot be empty');
    }
    if (questions.length > 100) {
      throw Exception('Too many questions (max 100)');
    }
  }

  /// Sanitize user input to prevent injection attacks
  String _sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(
          RegExp(r'''[<>"']'''),
          '',
        ) // Remove potentially dangerous characters
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }

  /// Generate secure interview ID
  String _generateSecureInterviewId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 31) % 1000000; // Simple hash for uniqueness
    return 'interview_${timestamp}_$random';
  }

  /// Save with retry mechanism
  Future<void> _saveWithRetry(
    Future<void> Function() saveFunction, {
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await saveFunction();
        return;
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      }
    }
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

  /// Cache session data securely
  void _cacheSessionData() {
    try {
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
    } catch (e) {
      debugPrint('❌ Error caching session data: $e');
    }
  }

  /// Clear session cache
  void _clearSessionCache() {
    try {
      CacheManager.remove(_currentInterviewKey);
      CacheManager.remove(_sessionQuestionsKey);
    } catch (e) {
      debugPrint('❌ Error clearing session cache: $e');
    }
  }

  /// Parse role string to Role enum with validation
  Role _parseRole(String roleString) {
    switch (roleString.toLowerCase().trim()) {
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
        debugPrint('⚠️ Unknown role: $roleString, defaulting to Flutter');
        return Role.flutter;
    }
  }

  /// Parse level string to Level enum with validation
  Level _parseLevel(String levelString) {
    switch (levelString.toLowerCase().trim()) {
      case 'intern':
        return Level.intern;
      case 'associate':
        return Level.associate;
      case 'senior':
        return Level.senior;
      default:
        debugPrint('⚠️ Unknown level: $levelString, defaulting to Associate');
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
