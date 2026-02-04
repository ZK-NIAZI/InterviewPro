import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../shared/domain/entities/interview.dart';
import '../../../../shared/domain/repositories/interview_repository.dart';
import '../providers/evaluation_provider.dart';
import '../widgets/candidate_info_card.dart';
import '../widgets/evaluation_form_widget.dart';

/// Candidate evaluation screen for assessing soft skills and generating reports
class CandidateEvaluationPage extends StatefulWidget {
  final String candidateName;
  final String role;
  final String level;
  final String interviewId;

  const CandidateEvaluationPage({
    super.key,
    required this.candidateName,
    required this.role,
    required this.level,
    required this.interviewId,
  });

  @override
  State<CandidateEvaluationPage> createState() =>
      _CandidateEvaluationPageState();
}

class _CandidateEvaluationPageState extends State<CandidateEvaluationPage> {
  Interview? _completedInterview;
  bool _loadingInterview = true;

  @override
  void initState() {
    super.initState();
    _loadInterviewData();

    // Load existing evaluation if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EvaluationProvider>().loadEvaluation(widget.interviewId);
    });
  }

  /// Load interview data from repository
  Future<void> _loadInterviewData() async {
    try {
      final interviewRepository = sl<InterviewRepository>();
      final interview = await interviewRepository.getInterviewById(
        widget.interviewId,
      );

      setState(() {
        _completedInterview = interview;
        _loadingInterview = false;
      });

      if (interview != null) {
        debugPrint('✅ Loaded interview data: ${interview.id}');
        debugPrint('Technical Score: ${interview.technicalScore}');
        debugPrint('Responses: ${interview.responses.length}');
      } else {
        debugPrint('⚠️ No interview found with ID: ${widget.interviewId}');
      }
    } catch (e) {
      debugPrint('❌ Error loading interview data: $e');
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

            // Main content
            Expanded(child: _buildMainContent()),

            // Bottom button
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
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
              child: Icon(
                Icons.chevron_left,
                size: 36,
                color: AppColors.primary,
              ),
            ),
          ),

          // Title and subtitle (centered)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  AppStrings.candidateEvaluation,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Soft Skills Assessment',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Invisible spacer to balance the back button
          SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Consumer<EvaluationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading || _loadingInterview) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Candidate info card - centered
              Center(
                child: CandidateInfoCard(
                  candidateName: widget.candidateName,
                  role: widget.role,
                  level: widget.level,
                  interviewDate: DateTime.now(),
                ),
              ),

              const SizedBox(height: 24),

              // Interview performance summary (if available)
              if (_completedInterview != null) ...[
                _buildInterviewPerformanceSummary(),
                const SizedBox(height: 24),
              ],

              // Evaluation form
              const EvaluationFormWidget(),
            ],
          ),
        );
      },
    );
  }

  /// Build interview performance summary widget
  Widget _buildInterviewPerformanceSummary() {
    final interview = _completedInterview!;
    final stats = interview.getPerformanceStats();
    final categoryPerformance = interview.calculateCategoryPerformance();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Interview Performance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Performance metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Technical Score',
                  '${(interview.technicalScore ?? 0).toStringAsFixed(1)}%',
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Questions Answered',
                  '${stats['answeredQuestions']}/${stats['totalQuestions']}',
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Correct Answers',
                  '${stats['correctAnswers']}',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Completion',
                  '${stats['completionPercentage'].toStringAsFixed(0)}%',
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Category breakdown
          const Text(
            'Category Performance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          ...categoryPerformance.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '${entry.value.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build metric card widget
  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
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

  Widget _buildBottomButton() {
    return Consumer<EvaluationProvider>(
      builder: (context, provider, child) {
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
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: provider.isFormValid && !provider.isSaving
                  ? () => _onGenerateReport(provider)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[500],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: provider.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assessment, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.generateReport,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onGenerateReport(EvaluationProvider provider) async {
    // Save evaluation
    final success = await provider.saveEvaluation(
      interviewId: widget.interviewId,
      candidateName: widget.candidateName,
      role: widget.role,
      level: widget.level,
    );

    if (!mounted) return;

    if (success) {
      // Calculate overall score using actual technical score
      double overallScore = provider.calculatedScore;
      if (_completedInterview != null) {
        final technicalScore = _completedInterview!.technicalScore ?? 0.0;
        final evaluationScore = provider.calculatedScore;
        // 70% technical + 30% soft skills evaluation
        overallScore = (technicalScore * 0.7) + (evaluationScore * 0.3);
      }

      // Show report with real data
      _showReportDialog(provider, overallScore);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save evaluation. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showReportDialog(EvaluationProvider provider, double overallScore) {
    // Navigate to interview report page with actual calculated data and interview ID
    final interviewId = _completedInterview?.id ?? widget.interviewId;
    final finalInterviewId = interviewId.isNotEmpty ? interviewId : '';
    context.push(
      '${AppRouter.interviewReport}?candidateName=${widget.candidateName}&role=${widget.role}&level=${widget.level}&overallScore=${overallScore.toStringAsFixed(1)}&communicationSkills=${provider.communicationSkills}&problemSolvingApproach=${provider.problemSolvingApproach}&culturalFit=${provider.culturalFit}&overallImpression=${provider.overallImpression}&additionalComments=${Uri.encodeComponent(provider.additionalComments)}&interviewId=$finalInterviewId',
    );
  }
}
