import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_router.dart';
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
  @override
  void initState() {
    super.initState();
    // Load existing evaluation if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EvaluationProvider>().loadEvaluation(widget.interviewId);
    });
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

          // Main content
          Expanded(child: _buildMainContent()),

          // Bottom button
          _buildBottomButton(),
        ],
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
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Candidate info card
              CandidateInfoCard(
                candidateName: widget.candidateName,
                role: widget.role,
                level: widget.level,
                interviewDate: DateTime.now(),
              ),

              const SizedBox(height: 24),

              // Evaluation form
              const EvaluationFormWidget(),
            ],
          ),
        );
      },
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
      // Generate report
      final report = await provider.generateReport(
        candidateName: widget.candidateName,
        role: widget.role,
        level: widget.level,
      );

      // Show report dialog
      _showReportDialog(report);
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

  void _showReportDialog(String report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          AppStrings.evaluationComplete,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            report,
            style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to dashboard
              context.go(AppRouter.dashboard);
            },
            child: Text(
              'Close',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
