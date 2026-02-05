import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../providers/report_data_provider.dart';
import '../widgets/circular_progress_widget.dart';
import '../widgets/quick_stats_widget.dart';
import '../widgets/question_breakdown_widget.dart';
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
  final String? interviewId; // Add interview ID for data loading

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
    this.interviewId,
  });

  @override
  State<InterviewReportPage> createState() => _InterviewReportPageState();
}

class _InterviewReportPageState extends State<InterviewReportPage> {
  @override
  void initState() {
    super.initState();
    // Load interview data if ID is provided
    if (widget.interviewId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ReportDataProvider>().loadInterviewData(
          widget.interviewId!,
        );
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
    return Consumer<ReportDataProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 140),
          child: Column(
            children: [
              // Candidate profile section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                  ),
                ),
                child: _buildCandidateProfile(provider.reportData),
              ),

              // Score hero section
              _buildScoreHero(provider.reportData),

              // Quick stats
              _buildQuickStats(provider.reportData),

              // Question breakdown
              if (provider.reportData != null)
                _buildQuestionBreakdown(provider.reportData!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error Loading Report',
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
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateProfile(ReportData? reportData) {
    return Column(
      children: [
        // Reuse CandidateInfoCard for consistency
        Center(
          child: CandidateInfoCard(
            candidateName: widget.candidateName,
            role: widget.role,
            level: widget.level,
            interviewDate: reportData?.interview.startTime ?? DateTime.now(),
          ),
        ),

        const SizedBox(height: 16),

        // Separate recommendation badge
        _buildRecommendationBadge(reportData),
      ],
    );
  }

  /// Builds the recommendation badge as a separate component
  Widget _buildRecommendationBadge(ReportData? reportData) {
    final score = reportData?.overallScore ?? widget.overallScore;
    final isRecommended = score >= 70.0;
    final color = isRecommended ? AppColors.primary : Colors.red;
    final text =
        reportData?.recommendation ??
        (isRecommended ? 'Recommended for Hire' : 'Not Recommended');
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

  Widget _buildScoreHero(ReportData? reportData) {
    final score = reportData?.overallScore ?? widget.overallScore;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: CircularProgressWidget(
        score: score,
        size: 192,
        label: 'Overall Score',
      ),
    );
  }

  Widget _buildQuickStats(ReportData? reportData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 32),
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
          QuickStatsWidget(
            totalQuestions: reportData?.totalQuestions ?? 25,
            correctAnswers:
                reportData?.correctAnswers ?? _calculateCorrectAnswers(),
            answeredQuestions: reportData?.answeredQuestions,
            completionPercentage: reportData?.completionPercentage,
            duration: reportData?.duration,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBreakdown(ReportData reportData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 32),
      child: QuestionBreakdownWidget(
        breakdown: reportData.questionBreakdown,
        showDetails: true,
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
          16,
          20,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          children: [
            // Download PDF button
            SizedBox(
              width: double.infinity,
              height: 44,
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

            const SizedBox(height: 8),
            // Share report button
            SizedBox(
              width: double.infinity,
              height: 44,
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

  void _onShareReport() {
    // TODO: Implement report sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report sharing feature coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _onDownloadReport() {
    // TODO: Implement report download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report download feature coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
