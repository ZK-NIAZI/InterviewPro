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

class _InterviewQuestionPageState extends State<InterviewQuestionPage> {
  bool? selectedAnswer; // null = no selection, true = Yes, false = No
  bool showNotes = false;
  final TextEditingController notesController = TextEditingController();

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
    return Column(
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

        const SizedBox(height: 24),

        // Add notes button
        _buildAddNotesButton(),

        // Notes input (if shown)
        if (showNotes) _buildNotesInput(),

        // Voice recording button (always visible)
        _buildVoiceRecordingButton(),
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

  Widget _buildAddNotesButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showNotes = !showNotes;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note,
              size: 20,
              color: showNotes ? AppColors.primary : Colors.grey[500],
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.addNotes,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: showNotes ? AppColors.primary : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesInput() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: notesController,
        maxLines: 2, // Reduced from 3
        minLines: 2, // Add minimum lines for consistency
        decoration: InputDecoration(
          hintText: AppStrings.addNotesHint,
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          contentPadding: EdgeInsets.zero, // Remove default padding
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }

  Widget _buildVoiceRecordingButton() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Center(
        child: GestureDetector(
          onTap: _onVoiceRecording,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(Icons.mic, size: 28, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextButton(
                onPressed: _onPrevious,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  AppStrings.previous,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Next button
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: _onNext,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  AppStrings.next,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNext() async {
    final question = _currentQuestion;
    if (question == null) return;

    // Validation: Ensure an option is selected
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Yes or No to continue'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Record response if session is active and answer is selected
    if (_sessionStarted && _sessionManager.hasActiveSession) {
      try {
        await _sessionManager.recordResponse(
          isCorrect: selectedAnswer!,
          notes: notesController.text.isNotEmpty ? notesController.text : null,
        );
        debugPrint('✅ Response recorded for question ${_currentIndex + 1}');
      } catch (e) {
        debugPrint('❌ Error recording response: $e');
      }
    }

    // Debug logging (for development)
    debugPrint('Question ${_currentIndex + 1}: ${question.question}');
    debugPrint(
      'Answer: ${selectedAnswer == null ? "No answer" : (selectedAnswer! ? "Yes" : "No")}',
    );
    debugPrint('Notes: ${notesController.text}');

    // Check if this is the last question
    if (_isLastQuestion()) {
      // Complete interview session and navigate to evaluation
      await _completeInterviewAndNavigate();
    } else {
      // Move to next question
      await _moveToNextQuestion();
    }
  }

  /// Complete interview session and navigate to evaluation
  Future<void> _completeInterviewAndNavigate() async {
    String candidateName = 'John Doe'; // Default fallback
    String? interviewId;

    debugPrint('🚀 Starting interview completion and navigation...');

    if (_sessionStarted && _sessionManager.hasActiveSession) {
      try {
        // Move to next question first to complete all responses
        if (_sessionManager.currentQuestionIndex <
            _sessionManager.totalQuestions - 1) {
          await _sessionManager.nextQuestion();
        }

        debugPrint('📝 Completing interview session...');
        // Complete the interview session
        final completedInterview = await _sessionManager.completeInterview();
        candidateName = completedInterview.candidateName;
        interviewId = completedInterview.id;

        debugPrint('✅ Interview completed: $interviewId');
        debugPrint('👤 Candidate: $candidateName');
      } catch (e) {
        debugPrint('❌ Error completing interview: $e');
      }
    } else {
      debugPrint('⚠️ No active session, using fallback data');
    }

    // Generate fallback ID only if we don't have one from the session
    if (interviewId == null) {
      interviewId = 'interview_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('⚠️ Using fallback interview ID: $interviewId');
    }

    // Navigate to candidate evaluation
    if (mounted) {
      final navigationUrl =
          '${AppRouter.candidateEvaluation}?candidateName=$candidateName&role=${widget.selectedRole}&level=${widget.selectedLevel}&interviewId=$interviewId';
      debugPrint('🧭 Navigating to: $navigationUrl');

      context.push(navigationUrl);
    }
  }

  /// Move to next question
  Future<void> _moveToNextQuestion() async {
    if (_sessionStarted && _sessionManager.hasActiveSession) {
      try {
        await _sessionManager.nextQuestion();
        setState(() {
          _currentQuestionIndex = _sessionManager.currentQuestionIndex;
          selectedAnswer = null; // Reset answer for next question
          showNotes = false; // Hide notes
          notesController.clear(); // Clear notes
        });
      } catch (e) {
        debugPrint('❌ Error moving to next question: $e');
        // Fallback to manual navigation
        setState(() {
          _currentQuestionIndex++;
          selectedAnswer = null;
          showNotes = false;
          notesController.clear();
        });
      }
    } else {
      // Fallback to manual navigation
      setState(() {
        _currentQuestionIndex++;
        selectedAnswer = null;
        showNotes = false;
        notesController.clear();
      });
    }
  }

  void _onPrevious() async {
    if (_currentIndex > 0) {
      if (_sessionStarted && _sessionManager.hasActiveSession) {
        try {
          await _sessionManager.previousQuestion();
          setState(() {
            _currentQuestionIndex = _sessionManager.currentQuestionIndex;
            selectedAnswer = null; // Reset answer
            showNotes = false; // Hide notes
            notesController.clear(); // Clear notes
          });
        } catch (e) {
          debugPrint('❌ Error moving to previous question: $e');
          // Fallback to manual navigation
          setState(() {
            _currentQuestionIndex--;
            selectedAnswer = null;
            showNotes = false;
            notesController.clear();
          });
        }
      } else {
        // Fallback to manual navigation
        setState(() {
          _currentQuestionIndex--;
          selectedAnswer = null;
          showNotes = false;
          notesController.clear();
        });
      }
    } else {
      context.pop();
    }
  }

  void _onVoiceRecording() {
    // Voice recording functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice recording feature coming soon'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Check if this is the last question
  bool _isLastQuestion() {
    return _currentIndex >= _totalQuestions - 1;
  }
}
