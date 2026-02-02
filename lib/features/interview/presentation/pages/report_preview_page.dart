import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/document_header_widget.dart';
import '../widgets/candidate_info_box_widget.dart';
import '../widgets/category_table_widget.dart';
import '../widgets/technical_questions_widget.dart';
import '../widgets/soft_skills_grid_widget.dart';
import '../widgets/recommendation_box_widget.dart';

/// Report preview screen showing PDF-style interview evaluation report
class ReportPreviewPage extends StatelessWidget {
  final String candidateName;
  final String role;
  final String level;
  final double overallScore;
  final int communicationSkills;
  final int problemSolvingApproach;
  final int culturalFit;
  final int overallImpression;
  final String additionalComments;

  const ReportPreviewPage({
    super.key,
    required this.candidateName,
    required this.role,
    required this.level,
    required this.overallScore,
    required this.communicationSkills,
    required this.problemSolvingApproach,
    required this.culturalFit,
    required this.overallImpression,
    required this.additionalComments,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: Stack(
        children: [
          Column(
            children: [
              // Status bar placeholder
              Container(
                height: MediaQuery.of(context).padding.top,
                decoration: const BoxDecoration(color: Color(0xFFF8F6F6)),
              ),

              // Header
              _buildHeader(context),

              // Main content
              Expanded(child: _buildMainContent()),
            ],
          ),

          // Floating action bar
          _buildFloatingActionBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F6F6),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 24,
                color: Color(0xFF1E293B),
              ),
            ),
          ),

          // Title (centered)
          const Expanded(
            child: Text(
              'Report Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: -0.015,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Share button
          GestureDetector(
            onTap: () => _onShare(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.share,
                size: 24,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 595),
          child: _buildPDFDocument(),
        ),
      ),
    );
  }

  Widget _buildPDFDocument() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document header
              const DocumentHeaderWidget(),

              const SizedBox(height: 24),

              // Candidate info box
              CandidateInfoBoxWidget(
                candidateName: candidateName,
                role: role,
                level: level,
                date: _formatDate(DateTime.now()),
              ),

              const SizedBox(height: 24),

              // Overall score section
              _buildOverallScoreSection(),

              const SizedBox(height: 24),

              // Category performance table
              CategoryTableWidget(categories: _generateCategoryData()),

              const SizedBox(height: 24),

              // Technical questions
              TechnicalQuestionsWidget(
                questions: _generateTechnicalQuestions(),
              ),

              const SizedBox(height: 24),

              // Soft skills
              SoftSkillsGridWidget(
                communicationSkills: communicationSkills,
                problemSolvingApproach: problemSolvingApproach,
                culturalFit: culturalFit,
                overallImpression: overallImpression,
              ),

              const SizedBox(height: 24),

              // Recommendation box
              RecommendationBoxWidget(overallScore: overallScore),

              const SizedBox(height: 24),

              // Comments section
              _buildCommentsSection(),

              const SizedBox(height: 32),

              // Footer
              _buildFooter(),
            ],
          ),
        ),

        // Watermark
        _buildWatermark(),
      ],
    );
  }

  Widget _buildOverallScoreSection() {
    final percentage = (overallScore * 10).toInt();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                height: 1.0,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'OVERALL SCORE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INTERVIEWER COMMENTS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          additionalComments.isNotEmpty
              ? '"$additionalComments"'
              : '"Candidate showed strong technical skills and good communication abilities. Recommended for the position based on overall performance and cultural fit."',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4B5563),
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.primary, width: 1)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generated by InterviewPro',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              Text(
                'Confidential Document',
                style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
          Text(
            'Page 1 of 1',
            style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildWatermark() {
    return Positioned.fill(
      child: Center(
        child: Opacity(
          opacity: 0.02,
          child: Icon(
            Icons.fact_check,
            size: 300,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionBar(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Download PDF button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onDownloadPDF,
                  borderRadius: BorderRadius.circular(24),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Download PDF',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Edit button
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF3F4F6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onEdit,
                  borderRadius: BorderRadius.circular(24),
                  child: Icon(Icons.edit, size: 20, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  List<CategoryData> _generateCategoryData() {
    return [
      CategoryData('Technical Knowledge', '4/5', _calculateTechnicalScore()),
      CategoryData('Problem Solving', '3/5', _calculateProblemSolvingScore()),
      CategoryData('System Design', '2/2', _calculateSystemDesignScore()),
      CategoryData('Communication', '5/5', _calculateCommunicationScore()),
    ];
  }

  List<TechnicalQuestion> _generateTechnicalQuestions() {
    return [
      TechnicalQuestion(
        'Explain the React Virtual DOM',
        'Candidate provided a clear explanation with examples.',
        communicationSkills >= 4,
      ),
      TechnicalQuestion(
        'Optimize a slow rendering list',
        'Correctly identified memoization and virtualization.',
        problemSolvingApproach >= 3,
      ),
      TechnicalQuestion(
        'Implement a custom Hook for fetching',
        'Struggled with cleanup function in useEffect.',
        overallImpression >= 4,
      ),
    ];
  }

  int _calculateTechnicalScore() =>
      ((communicationSkills + problemSolvingApproach) / 2 * 20).round();
  int _calculateProblemSolvingScore() => (problemSolvingApproach * 20).round();
  int _calculateSystemDesignScore() =>
      ((overallImpression + culturalFit) / 2 * 20).round();
  int _calculateCommunicationScore() => (communicationSkills * 20).round();

  void _onDownloadPDF() {
    // TODO: Implement PDF download
  }

  void _onEdit() {
    // Navigate back to previous screen
  }

  void _onShare() {
    // TODO: Implement share functionality
  }
}

// Data classes
class CategoryData {
  final String name;
  final String questions;
  final int score;

  CategoryData(this.name, this.questions, this.score);
}

class TechnicalQuestion {
  final String question;
  final String feedback;
  final bool isCorrect;

  TechnicalQuestion(this.question, this.feedback, this.isCorrect);
}
