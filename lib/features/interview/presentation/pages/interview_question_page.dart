import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/interview_session_manager.dart';
import '../../../../shared/domain/entities/interview_question.dart';
import '../providers/interview_question_provider.dart';
import '../providers/voice_recording_provider.dart';

/// Interview question screen matching the provided HTML design
class InterviewQuestionPage extends StatefulWidget {
  final String selectedRole;
  final String selectedLevel;
  final String candidateName;

  const InterviewQuestionPage({
    super.key,
    required this.selectedRole,
    required this.selectedLevel,
    required this.candidateName,
  });

  @override
  State<InterviewQuestionPage> createState() => _InterviewQuestionPageState();
}

class _InterviewQuestionPageState extends State<InterviewQuestionPage>
    with SingleTickerProviderStateMixin {
  bool? selectedAnswer; // null = no selection, true = Yes, false = No
  final TextEditingController notesController = TextEditingController();

  // Voice recording state
  // (Animation logic removed as per interview-wide session design)

  // Dynamic question data
  List<InterviewQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  String? _error;

  // Interview session manager
  late final InterviewSessionManager _sessionManager;
  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();
    _sessionManager = sl<InterviewSessionManager>();
    _loadQuestions();
  }

  /// Load questions based on selected role and experience level
  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final provider = context.read<InterviewQuestionProvider>();

      // Load questions filtered by role and difficulty level
      final questions = await provider.getRandomQuestions(
        count: 25, // Get 25 questions for the interview
        roleSpecific: widget.selectedRole,
        difficulty: _mapExperienceLevelToDifficulty(widget.selectedLevel),
      );

      // If no role-specific questions, get general questions
      if (questions.isEmpty) {
        final generalQuestions = await provider.getRandomQuestions(
          count: 25,
          difficulty: _mapExperienceLevelToDifficulty(widget.selectedLevel),
        );

        setState(() {
          _questions = generalQuestions;
          _isLoading = false;
        });
      } else {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }

      if (_questions.isEmpty) {
        setState(() {
          _error = 'No questions found for the selected criteria';
        });
        return;
      }

      // Start interview session after questions are loaded
      await _startInterviewSession();
    } catch (e) {
      setState(() {
        _error = 'Failed to load questions: $e';
        _isLoading = false;
      });
    }
  }

  /// Start interview session with loaded questions
  Future<void> _startInterviewSession() async {
    try {
      await _sessionManager.startInterview(
        candidateName: widget.candidateName,
        role: widget.selectedRole,
        level: widget.selectedLevel,
        questions: _questions,
      );

      setState(() {
        _sessionStarted = true;
        _currentQuestionIndex = _sessionManager.currentQuestionIndex;
      });

      debugPrint('✅ Interview session started successfully');
    } catch (e) {
      debugPrint('❌ Error starting interview session: $e');
      // Continue without session tracking if it fails
      setState(() {
        _sessionStarted = false;
      });
    }
  }

  /// Map experience level to difficulty
  String _mapExperienceLevelToDifficulty(String level) {
    switch (level.toLowerCase()) {
      case 'intern':
        return 'beginner';
      case 'associate':
        return 'intermediate';
      case 'senior':
        return 'advanced';
      default:
        return 'intermediate';
    }
  }

  /// Get current question
  InterviewQuestion? get _currentQuestion {
    if (_sessionStarted && _sessionManager.hasActiveSession) {
      return _sessionManager.getCurrentQuestion();
    }

    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }

  /// Get total questions count
  int get _totalQuestions {
    if (_sessionStarted && _sessionManager.hasActiveSession) {
      return _sessionManager.totalQuestions;
    }
    return _questions.length;
  }

  /// Get current question index
  int get _currentIndex {
    if (_sessionStarted && _sessionManager.hasActiveSession) {
      return _sessionManager.currentQuestionIndex;
    }
    return _currentQuestionIndex;
  }

  @override
  void dispose() {
    notesController.dispose();
    // Note: We don't clear the session here as it should persist
    // until the interview is completed or explicitly cancelled
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: _isLoading
            ? _buildLoadingState()
            : _error != null
            ? _buildErrorState()
            : _questions.isEmpty
            ? _buildEmptyState()
            : _buildQuestionContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading interview questions...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error Loading Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.red[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadQuestions,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Questions Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'No questions found for ${widget.selectedRole} at ${widget.selectedLevel} level.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadQuestions,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reload Questions'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    final provider = context.watch<VoiceRecordingProvider>();
    final isRecording = provider.isRecording;

    return Stack(
      children: [
        // Main content column
        Column(
          children: [
            // Status bar placeholder
            Container(
              height: MediaQuery.of(context).padding.top,
              decoration: const BoxDecoration(color: Colors.white),
            ),

            // Header
            _buildHeader(),

            // Progress bar
            _buildProgressBar(),

            // Main content
            Expanded(child: _buildMainContent()),

            // Bottom navigation
            _buildBottomNavigation(),
          ],
        ),

        // Floating Action Button for Voice Recording
        // Positioned as a separate overlay to ensure tap detection works
        Positioned(
          left: 0,
          right: 0,
          bottom: 100, // Positioned above the bottom navigation
          child: IgnorePointer(
            ignoring: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Recording Time (if active) - positioned above FAB
                  if (isRecording)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatDuration(provider.recordingDurationSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  // Voice Recorder FAB
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: FloatingActionButton(
                      onPressed: _toggleRecording,
                      backgroundColor: isRecording
                          ? AppColors.primary
                          : Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(
                          color: isRecording
                              ? Colors.transparent
                              : AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        color: isRecording ? Colors.white : AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.close, size: 28, color: Colors.black),
            ),
          ),

          // Question counter
          Text(
            'QUESTION ${_currentIndex + 1} OF $_totalQuestions',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentIndex + 1) / _totalQuestions;

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        height: 6,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(3),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          24,
          0,
          24,
          20,
        ), // Significantly reduced from 100
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question number
            _buildQuestionNumber(),

            const SizedBox(height: 16),

            // Question text
            _buildQuestionText(),

            const SizedBox(height: 48),

            // Answer section
            _buildAnswerSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionNumber() {
    return Text(
      '#${_currentIndex + 1}',
      style: TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
        height: 1.0,
        letterSpacing: -2,
      ),
    );
  }

  Widget _buildQuestionText() {
    final question = _currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return Text(
      question.question,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        height: 1.2,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildAnswerSection() {
    return Column(
      children: [
        // Yes/No buttons
        _buildYesNoButtons(),

        const SizedBox(height: 32),

        // Notes Label
        const Row(
          children: [
            Icon(Icons.edit_note, size: 20, color: Color(0xFF64748B)),
            SizedBox(width: 8),
            Text(
              'Interview Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),

        // Notes input (ALWAYS VISIBLE)
        _buildNotesInput(),

        // Extra padding to avoid overlap with FAB/Bottom Nav
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildYesNoButtons() {
    return Row(
      children: [
        // No button
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedAnswer = false;
              });
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: selectedAnswer == false
                    ? Colors.grey[200]
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: selectedAnswer == false
                      ? Colors.grey[400]!
                      : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    size: 24,
                    color: selectedAnswer == false
                        ? Colors.grey[600]
                        : Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.no,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: selectedAnswer == false
                          ? Colors.grey[700]
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Yes button
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedAnswer = true;
              });
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: selectedAnswer == true
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: selectedAnswer == true
                      ? AppColors.primary
                      : Colors.grey[300]!,
                  width: 1,
                ),
                boxShadow: selectedAnswer == true
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 24,
                    color: selectedAnswer == true
                        ? Colors.white
                        : Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.yes,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: selectedAnswer == true
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: TextField(
        controller: notesController,
        maxLines: 4,
        minLines: 3,
        decoration: InputDecoration(
          hintText: 'Type your observations here...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
        ),
        style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _toggleRecording() async {
    final provider = context.read<VoiceRecordingProvider>();
    if (provider.isRecording) {
      await provider.stop();
    } else {
      try {
        await provider.start(
          interviewId: _sessionManager.currentInterview?.id ?? 'temp',
          candidateName: widget.candidateName,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Microphone error: $e')));
        }
      }
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (_currentIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _onPrevious,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Previous',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),

          if (_currentIndex > 0) const SizedBox(width: 16),

          // Next button
          Expanded(
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentIndex == _totalQuestions - 1 ? 'Complete' : 'Next',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPrevious() {
    _sessionManager.previousQuestion();
    setState(() {
      _currentQuestionIndex = _sessionManager.currentQuestionIndex;
      // Load existing result if available
      final existingResult = _sessionManager.getResponseForQuestion(
        _currentIndex,
      );
      if (existingResult != null) {
        selectedAnswer = existingResult.isCorrect;
        notesController.text = existingResult.notes ?? '';
      } else {
        selectedAnswer = null;
        notesController.text = '';
      }
    });
  }

  void _onNext() async {
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an answer (Yes/No)')),
      );
      return;
    }

    try {
      // Record current response
      await _sessionManager.recordResponse(
        isCorrect: selectedAnswer!,
        notes: notesController.text,
      );

      if (_currentIndex < _totalQuestions - 1) {
        await _sessionManager.nextQuestion();
        setState(() {
          _currentQuestionIndex = _sessionManager.currentQuestionIndex;
          // Check if next question already answered
          final existingResult = _sessionManager.getResponseForQuestion(
            _currentIndex,
          );
          if (existingResult != null) {
            selectedAnswer = existingResult.isCorrect;
            notesController.text = existingResult.notes ?? '';
          } else {
            selectedAnswer = null;
            notesController.text = '';
          }
        });
      } else {
        // Handle interview completion
        _completeInterview();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _completeInterview() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      // STOP Recording if it's active
      final recordingProvider = context.read<VoiceRecordingProvider>();
      String? recordingPath;
      int recordingDuration = 0;

      if (recordingProvider.isRecording) {
        recordingDuration = recordingProvider.recordingDurationSeconds;
        recordingPath = await recordingProvider.stop();
      }

      // Complete interview in manager and capture the returned interview data
      final completedInterview = await _sessionManager.completeInterview(
        voiceRecordingPath: recordingPath,
        voiceRecordingDurationSeconds: recordingDuration,
      );

      // Update interview with recording details if available
      debugPrint('📽️ Recording saved at: $recordingPath');
      debugPrint('✅ Interview completed: ${completedInterview.id}');

      if (mounted) {
        Navigator.pop(context); // Remove loading

        // Navigate to candidate evaluation page with interview data
        context.go(
          '${AppRouter.candidateEvaluation}?candidateName=${Uri.encodeComponent(completedInterview.candidateName)}&role=${Uri.encodeComponent(completedInterview.roleName)}&level=${Uri.encodeComponent(completedInterview.level.name)}&interviewId=${completedInterview.id}',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Remove loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to complete: $e')));
      }
    }
  }
}
