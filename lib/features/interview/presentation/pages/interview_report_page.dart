import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../widgets/circular_progress_widget.dart';
import '../widgets/category_performance_widget.dart';
import '../widgets/quick_stats_widget.dart';

/// Interview report screen showing detailed evaluation results
class InterviewReportPage extends StatelessWidget {
  final String candidateName;
  final String role;
  final String level;
  final double overallScore;
  final int communicationSkills;
  final int problemSolvingApproach;
  final int culturalFit;
  final int overallImpression;
  final String additionalComments;

  const InterviewReportPage({
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Black icons for light theme
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: Stack(
          children: [
            Column(
              children: [
                // Status bar placeholder
                Container(
                  height: MediaQuery.of(context).padding.top,
                  decoration: const BoxDecoration(color: Colors.white),
                ),

                // Header
                _buildHeader(context),

                // Main content
                Expanded(child: _buildMainContent()),
              ],
            ),

            // Bottom actions
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 24,
                color: Colors.black,
              ),
            ),
          ),

          // Title (centered)
          const Expanded(
            child: Text(
              'Interview Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Action buttons
          Row(
            children: [
              GestureDetector(
                onTap: () => _onShareReport(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.share, size: 20, color: Colors.black),
                ),
              ),
              GestureDetector(
                onTap: () => _onDownloadReport(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.download,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 140), // Increased from 120
      child: Column(
        children: [
          // Candidate profile section
          _buildCandidateProfile(),

          // Score hero section
          _buildScoreHero(),

          // Category performance
          _buildCategoryPerformance(),

          // Quick stats (with overflow fix)
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildCandidateProfile() {
    return Container(
      padding: const EdgeInsets.all(24), // Increased padding
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: Column(
        children: [
          // Remove Stack with profile picture entirely

          // Candidate name (more prominent)
          Text(
            candidateName,
            style: const TextStyle(
              fontSize: 28, // Increased from 22
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Role (enhanced styling with smaller font)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$role - $level',
              style: TextStyle(
                fontSize: 14, // Reduced from 18
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Interview date (better styling with smaller font)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  'Interview Date: ${_formatDate(DateTime.now())}',
                  style: TextStyle(
                    fontSize: 12, // Reduced from 15
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Recommendation badge (enhanced)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 24, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Recommended for Hire',
                  style: TextStyle(
                    fontSize: 16, // Increased from 14
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHero() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: CircularProgressWidget(score: overallScore, size: 192),
    );
  }

  Widget _buildCategoryPerformance() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          CategoryPerformanceWidget(
            categories: [
              CategoryData(
                'Programming',
                _calculateCategoryScore([
                  communicationSkills,
                  problemSolvingApproach,
                ]),
              ),
              CategoryData(
                'Soft Skills',
                _calculateCategoryScore([communicationSkills, culturalFit]),
              ),
              CategoryData(
                'System Design',
                _calculateCategoryScore([
                  problemSolvingApproach,
                  overallImpression,
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          // Simple container without complex constraints
          QuickStatsWidget(
            totalQuestions: 25,
            correctAnswers: _calculateCorrectAnswers(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          16, // Reduced from 20
          20,
          MediaQuery.of(context).padding.bottom + 20, // Reduced from 32
        ),
        child: Column(
          children: [
            // Download PDF button (reduced height)
            SizedBox(
              width: double.infinity,
              height: 44, // Reduced from 48
              child: ElevatedButton(
                onPressed: () => _onDownloadPDF(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: AppColors.primary.withValues(alpha: 0.2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Preview PDF',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8), // Reduced from 12
            // Share report button (reduced height)
            SizedBox(
              width: double.infinity,
              height: 44, // Reduced from 48
              child: OutlinedButton(
                onPressed: _onShareReport,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey[200]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ios_share, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Share Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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

  double _calculateCategoryScore(List<int> ratings) {
    if (ratings.isEmpty) return 0.0;
    final average = ratings.reduce((a, b) => a + b) / ratings.length;
    return (average / 5.0) * 100.0;
  }

  int _calculateCorrectAnswers() {
    final totalRating =
        communicationSkills +
        problemSolvingApproach +
        culturalFit +
        overallImpression;
    return ((totalRating / 20.0) * 25).round();
  }

  void _onDownloadPDF(BuildContext context) {
    // Navigate to report preview
    context.push(
      '${AppRouter.reportPreview}?candidateName=$candidateName&role=$role&level=$level&overallScore=$overallScore&communicationSkills=$communicationSkills&problemSolvingApproach=$problemSolvingApproach&culturalFit=$culturalFit&overallImpression=$overallImpression&additionalComments=${Uri.encodeComponent(additionalComments)}',
    );
  }

  void _onShareReport() {}

  void _onDownloadReport() {}
}

// Data class for category performance
class CategoryData {
  final String name;
  final double percentage;

  CategoryData(this.name, this.percentage);
}
