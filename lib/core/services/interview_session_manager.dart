import 'package:flutter/foundation.dart';
import '../../shared/domain/entities/entities.dart';
import '../../shared/domain/repositories/interview_repository.dart';
import 'cache_manager.dart';
import '../services/transcription_service.dart';
import '../services/voice_recording_service.dart';
import '../services/upload_queue_service.dart';
import '../services/service_locator.dart';

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

  InterviewSessionManager(this._interviewRepository) {
    _listenToTranscriptionResults();
  }

  /// Listen for background transcription results and persist them immediately
  void _listenToTranscriptionResults() {
    try {
      final transcriptionService = sl<TranscriptionService>();
      transcriptionService.statusStream.listen((results) async {
        for (final entry in results.entries) {
          final interviewId = entry.key;
          final transcript = entry.value;

          debugPrint('💾 Auto-persisting transcript for: $interviewId');
          try {
            final interview = await _interviewRepository.getInterviewById(
              interviewId,
            );
            if (interview != null) {
              // Smart Persistence: Allow overwriting if existing transcript is null, empty,
              // or legacy text (but the new one is structured JSON)
              final bool shouldUpdate =
                  interview.transcript == null ||
                  interview.transcript!.isEmpty ||
                  _isBetterTranscript(
                    oldTranscript: interview.transcript!,
                    newTranscript: transcript,
                  );

              if (shouldUpdate) {
                final updatedInterview = interview.copyWith(
                  transcript: transcript,
                );
                await _saveWithRetry(
                  () => _interviewRepository.updateInterview(updatedInterview),
                );
                debugPrint(
                  '✅ Successfully persisted transcript for: $interviewId',
                );
              } else {
                debugPrint(
                  'ℹ️ Skipping persistence: Existing transcript is already up-to-date.',
                );
              }
            }
          } catch (e) {
            debugPrint(
              '❌ Failed to auto-persist transcript for $interviewId: $e',
            );
          }
        }
      });
    } catch (e) {
      debugPrint('⚠️ Error initializing transcription listener: $e');
    }
  }

  /// Detects if a new transcript is "better" (e.g. JSON vs Plain Text)
  bool _isBetterTranscript({
    required String oldTranscript,
    required String newTranscript,
  }) {
    final oldIsJson =
        oldTranscript.trim().startsWith('[') &&
        oldTranscript.trim().endsWith(']');
    final newIsJson =
        newTranscript.trim().startsWith('[') &&
        newTranscript.trim().endsWith(']');

    // If new is JSON and old is NOT, then it's definitely better
    if (newIsJson && !oldIsJson) return true;

    // Otherwise, we don't automatically overwrite existing content
    return false;
  }

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

      final sanitizedCandidateName = _sanitizeInput(candidateName);
      // Create new interview entity with secure ID
      final interview = Interview(
        id: _generateSecureInterviewId(sanitizedCandidateName),
        candidateName: sanitizedCandidateName,
        role: _parseRole(role),
        roleName: role.trim(),
        level: _parseLevel(level),
        startTime: DateTime.now(),
        lastModified: DateTime.now(),
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

      // Cleanup orphaned recordings on session start
      try {
        final recordingService = sl<VoiceRecordingService>();
        final interviews = await _interviewRepository.getAllInterviews();
        await recordingService.cleanupOrphanedRecordings(
          interviews.map((i) => i.id).toList(),
        );
      } catch (e) {
        debugPrint('⚠️ Initial cleanup failed: $e');
      }

      debugPrint(
        '✅ Started interview session (In-Memory/Cache): ${interview.id}',
      );
      notifyListeners();

      return interview;
    } catch (e) {
      debugPrint('❌ Error starting interview session: $e');
      _clearSession();
      rethrow;
    }
  }

  /// Record a response to the current question with enhanced validation
  Future<void> recordResponse({
    required bool isCorrect,
    String? notes,
    String? voiceRecordingPath,
    int? voiceRecordingDurationSeconds,
  }) async {
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
        voiceRecordingPath: voiceRecordingPath,
        voiceRecordingDurationSeconds: voiceRecordingDurationSeconds,
      );

      // Add response to current interview
      final updatedResponses = [..._currentInterview!.responses, response];

      // Update interview
      _currentInterview = _currentInterview!.copyWith(
        responses: updatedResponses,
        // technicalScore is calculated dynamically
      );

      // Cache updated session
      _cacheSessionData();

      debugPrint(
        '✅ Recorded response for question ${currentQuestionIndex + 1} (Cached)',
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

      debugPrint('✅ Moved to question ${currentQuestionIndex + 1} (Cached)');
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

      debugPrint('✅ Moved to question ${currentQuestionIndex + 1} (Cached)');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error moving to previous question: $e');
      rethrow;
    }
  }

  /// Complete the interview session with enhanced validation
  Future<Interview> completeInterview({
    String? voiceRecordingPath,
    int? voiceRecordingDurationSeconds,
  }) async {
    if (_currentInterview == null) {
      throw Exception('No active interview session');
    }

    try {
      debugPrint(
        '🏁 Starting interview completion for: ${_currentInterview!.id}',
      );

      // Score is calculated dynamically via the Entity getter
      debugPrint(
        '📊 Final technical score: ${_currentInterview!.technicalScore}',
      );

      // Update interview status
      _currentInterview = _currentInterview!.copyWith(
        status: InterviewStatus.completed,
        endTime: DateTime.now(),
        // technicalScore is calculated dynamically
        voiceRecordingPath: voiceRecordingPath,
        voiceRecordingDurationSeconds: voiceRecordingDurationSeconds,
      );

      debugPrint('✅ Interview updated with completion data');

      debugPrint('🆔 Interview ID: ${_currentInterview!.id}');
      debugPrint('👤 Candidate: ${_currentInterview!.candidateName}');
      debugPrint('📊 Status: ${_currentInterview!.status}');

      // Cleanup redundant recordings for this interview
      try {
        final recordingService = sl<VoiceRecordingService>();
        if (voiceRecordingPath != null) {
          await recordingService.cleanupRedundantRecordings(
            _currentInterview!.id,
            voiceRecordingPath,
          );
        }
      } catch (e) {
        debugPrint('⚠️ Redundant recording cleanup failed: $e');
      }

      // Optimization: Save to repository BEFORE STT to ensure metadata safety
      debugPrint('💾 Saving completed interview to repository...');
      await _saveWithRetry(
        () => _interviewRepository.updateInterview(_currentInterview!),
      );
      debugPrint('✅ Interview saved to repository successfully');

      // Proactive STT Trigger: Start transcription immediately AFTER record is safe in DB
      if (voiceRecordingPath != null && voiceRecordingPath.isNotEmpty) {
        // 1. Queue Upload to Google Drive (Resilient)
        try {
          final uploadService = sl<UploadQueueService>();
          // Generate a placeholder email since we don't capture it yet
          // This ensures unique constraints in Appwrite don't break if we use a common placeholder
          final sanitizedCandidate = _currentInterview!.candidateName
              .replaceAll(RegExp(r'\s+'), '.')
              .toLowerCase();
          final placeholderEmail = '$sanitizedCandidate@interview.pro';

          uploadService.addToQueue(
            interviewId: _currentInterview!.id,
            filePath: voiceRecordingPath,
            candidateName: _currentInterview!.candidateName,
            candidateEmail: placeholderEmail,
          );
          debugPrint('☁️ Queued recording for upload: $voiceRecordingPath');
        } catch (e) {
          debugPrint('⚠️ Failed to queue upload: $e');
        }

        // 2. Queue Local Transcription (Existing Logic)
        try {
          final transcriptionService = sl<TranscriptionService>();
          transcriptionService.queueTranscription(
            _currentInterview!.id,
            voiceRecordingPath,
          );
        } catch (e) {
          debugPrint('⚠️ Failed to queue proactive STT: $e');
        }
      }

      // Clear session cache
      _clearSessionCache();

      debugPrint('✅ Completed interview session: ${_currentInterview!.id}');

      final completedInterview = _currentInterview!;

      // Clear current session
      _clearSession();
      debugPrint('🧹 Session cleared from memory');

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

  /// Generate readable secure interview ID
  /// Format: name-timestamp-random (max 36 chars)
  String _generateSecureInterviewId(String candidateName) {
    // 1. Sanitize: alphanumeric, hyphen, underscore only. Lowercase.
    final slug = candidateName
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-') // Space to hyphen
        .replaceAll(RegExp(r'[^a-z0-9\-_]'), ''); // Remove specials

    // 2. Truncate name (max 20 chars to leave room for 15-char suffix)
    final shortSlug = slug.length > 20 ? slug.substring(0, 20) : slug;
    final prefix = shortSlug.isEmpty ? 'interview' : shortSlug;

    // 3. Timestamp (seconds) & Random
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final random = DateTime.now().millisecondsSinceEpoch % 1000;

    // Example: john-doe-1712345678-123
    return '$prefix-$timestamp-$random';
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

  /// Parse role string to Role enum for Icon/UI purposes only.
  /// Does NOT affect the stored roleName.
  Role _parseRole(String roleString) {
    final normalized = roleString.toLowerCase().trim();
    if (normalized.contains('flutter')) return Role.flutter;
    if (normalized.contains('backend')) return Role.backend;
    if (normalized.contains('frontend')) return Role.frontend;
    if (normalized.contains('full stack') || normalized.contains('fullstack')) {
      return Role.fullStack;
    }
    if (normalized.contains('mobile')) return Role.mobile;

    // Structural fallback for Icons, but the actual data is preserved in roleName
    return Role.flutter;
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
