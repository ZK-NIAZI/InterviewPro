import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Interview question screen matching the provided HTML design
class InterviewQuestionPage extends StatefulWidget {
  final String selectedRole;
  final String selectedLevel;

  const InterviewQuestionPage({
    super.key,
    required this.selectedRole,
    required this.selectedLevel,
  });

  @override
  State<InterviewQuestionPage> createState() => _InterviewQuestionPageState();
}

class _InterviewQuestionPageState extends State<InterviewQuestionPage> {
  bool? selectedAnswer; // null = no selection, true = Yes, false = No
  bool showNotes = false;
  final TextEditingController notesController = TextEditingController();

  // Mock data - in real app this would come from the question repository
  static const int _currentQuestion = 5;
  static const int _totalQuestions = 25;
  static const String _category = 'Programming Fundamentals';
  static const String _questionText =
      'Explain the difference between const and final in Dart?';

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
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
            'QUESTION $_currentQuestion OF $_totalQuestions',
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
    final progress = _currentQuestion / _totalQuestions;

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
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category chip
            _buildCategoryChip(),

            const SizedBox(height: 24),

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

  Widget _buildCategoryChip() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: Center(
        child: Text(
          _category,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionNumber() {
    return Text(
      '#$_currentQuestion',
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
    return Text(
      _questionText,
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
        maxLines: 3,
        decoration: InputDecoration(
          hintText: AppStrings.addNotesHint,
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black),
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
                onPressed: () => context.pop(),
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

  void _onNext() {
    // In a real app, this would save the answer and navigate to the next question
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedAnswer == null
              ? AppStrings.pleaseSelectAnswer
              : 'Answer saved: ${selectedAnswer! ? AppStrings.yes : AppStrings.no}',
        ),
        backgroundColor: selectedAnswer == null
            ? Colors.orange
            : AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate to next question or complete interview
    if (selectedAnswer != null) {
      // For demo purposes, just pop back to previous screen
      // In real app, this would navigate to next question or results
      context.pop();
    }
  }
}
