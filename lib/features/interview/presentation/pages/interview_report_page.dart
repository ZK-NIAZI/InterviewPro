import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../shared/domain/entities/interview.dart';
import '../../../../shared/domain/entities/enums.dart';
import '../../../../shared/domain/repositories/interview_repository.dart';
import '../widgets/circular_progress_widget.dart';
import '../widgets/category_performance_widget.dart';
import '../widgets/quick_stats_widget.dart';
import '../widgets/candidate_info_card.dart';

/// Interview report screen showing detailed evaluation results
class InterviewReportPage extends StatefulWidget {
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
  State<InterviewReportPage> createState() => _InterviewReportPageState();
}

class _InterviewReportPageState extends State<InterviewReportPage> {
  Interview? _interviewData;
  bool _loadingInterview = true;

  @override
  void initState() {
    super.initState();
    _loadInterviewData();
  }

  /// Load interview data to get actual performance metrics
  Future<void> _loadInterviewData() async {
    try {
      final interviewRepository = sl<InterviewRepository>();

      // Try to find recent completed interviews
      final interviews = await interviewRepository.getInterviewsByStatus(
        InterviewStatus.completed,
      );

      if (interviews.isNotEmpty) {
        // Get the most recent completed interview (assuming it's for this candidate)
        interviews.sort((a, b) => b.startTime.compareTo(a.startTime));
        _interviewData = interviews.first;
        debugPrint('✅ Loaded interview data for report: ${_interviewData!.id}');
      } else {
        debugPrint('⚠️ No completed interviews found');
      }
    } catch (e) {
      debugPrint('❌ Error loading interview data for report: $e');
    } finally {
      setState(() {
        _loadingInterview = false;
      });
    }
  }

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
    if (_loadingInterview) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 140),
      child: Column(
        children: [
          // Candidate profile section (now using CandidateInfoCard)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
              ),
            ),
            child: _buildCandidateProfile(),
          ),

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
    return Column(
      children: [
        // Reuse CandidateInfoCard for consistency
        Center(
          child: CandidateInfoCard(
            candidateName: widget.candidateName,
            role: widget.role,
            level: widget.level,
            interviewDate: DateTime.now(),
          ),
        ),

        const SizedBox(height: 16),

        // Separate recommendation badge
        _buildRecommendationBadge(),
      ],
    );
  }

  /// Builds the recommendation badge as a separate component
  Widget _buildRecommendationBadge() {
    final isRecommended = widget.overallScore >= 70.0;
    final color = isRecommended ? AppColors.primary : Colors.red;
    final text = isRecommended ? 'Recommended for Hire' : 'Not Recommended';
    final icon = isRecommended ? Icons.verified : Icons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHero() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: CircularProgressWidget(score: widget.overallScore, size: 192),
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
          CategoryPerformanceWidget(categories: _getCategoryPerformanceData()),
        ],
      ),
    );
  }

  /// Get category performance data from actual interview or fallback to evaluation
  List<CategoryData> _getCategoryPerformanceData() {
    if (_interviewData != null) {
      // Use actual interview performance data
      final categoryPerformance = _interviewData!
          .calculateCategoryPerformance();
      return [
        CategoryData('Programming', categoryPerformance['Programming'] ?? 0.0),
        CategoryData('Soft Skills', categoryPerformance['Soft Skills'] ?? 0.0),
        CategoryData(
          'System Design',
          categoryPerformance['System Design'] ?? 0.0,
        ),
      ];
    } else {
      // Fallback to evaluation-based calculation
      return [
        CategoryData(
          'Programming',
          _calculateCategoryScore([
            widget.communicationSkills,
            widget.problemSolvingApproach,
          ]),
        ),
        CategoryData(
          'Soft Skills',
          _calculateCategoryScore([
            widget.communicationSkills,
            widget.culturalFit,
          ]),
        ),
        CategoryData(
          'System Design',
          _calculateCategoryScore([
            widget.problemSolvingApproach,
            widget.overallImpression,
          ]),
        ),
      ];
    }
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
            totalQuestions: _getTotalQuestions(),
            correctAnswers: _getCorrectAnswers(),
          ),
        ],
      ),
    );
  }

  /// Get total questions from actual interview data or fallback
  int _getTotalQuestions() {
    if (_interviewData != null) {
      return _interviewData!.totalQuestions;
    }
    return 25; // Default fallback
  }

  /// Get correct answers from actual interview data or calculated estimate
  int _getCorrectAnswers() {
    if (_interviewData != null) {
      final stats = _interviewData!.getPerformanceStats();
      return stats['correctAnswers'] as int;
    }
    // Fallback calculation based on evaluation scores
    return _calculateCorrectAnswers();
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

  double _calculateCategoryScore(List<int> ratings) {
    if (ratings.isEmpty) return 0.0;
    final average = ratings.reduce((a, b) => a + b) / ratings.length;
    return (average / 5.0) * 100.0;
  }

  int _calculateCorrectAnswers() {
    final totalRating =
        widget.communicationSkills +
        widget.problemSolvingApproach +
        widget.culturalFit +
        widget.overallImpression;
    return ((totalRating / 20.0) * 25).round();
  }

  void _onDownloadPDF(BuildContext context) {
    // Navigate to report preview
    context.push(
      '${AppRouter.reportPreview}?candidateName=${widget.candidateName}&role=${widget.role}&level=${widget.level}&overallScore=${widget.overallScore}&communicationSkills=${widget.communicationSkills}&problemSolvingApproach=${widget.problemSolvingApproach}&culturalFit=${widget.culturalFit}&overallImpression=${widget.overallImpression}&additionalComments=${Uri.encodeComponent(widget.additionalComments)}',
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
