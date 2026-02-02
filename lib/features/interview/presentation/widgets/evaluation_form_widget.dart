import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/evaluation_provider.dart';
import 'star_rating_widget.dart';

/// Form widget for candidate evaluation
class EvaluationFormWidget extends StatefulWidget {
  const EvaluationFormWidget({super.key});

  @override
  State<EvaluationFormWidget> createState() => _EvaluationFormWidgetState();
}

class _EvaluationFormWidgetState extends State<EvaluationFormWidget> {
  final TextEditingController _commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize comments controller with provider value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EvaluationProvider>();
      _commentsController.text = provider.additionalComments;
    });
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EvaluationProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form title
              _buildFormTitle(),

              const SizedBox(height: 24),

              // Rating sections
              _buildRatingSection(
                label: AppStrings.communicationSkills,
                rating: provider.communicationSkills,
                onRatingChanged: provider.updateCommunicationSkills,
              ),

              const SizedBox(height: 20),

              _buildRatingSection(
                label: AppStrings.problemSolvingApproach,
                rating: provider.problemSolvingApproach,
                onRatingChanged: provider.updateProblemSolvingApproach,
              ),

              const SizedBox(height: 20),

              _buildRatingSection(
                label: AppStrings.culturalFit,
                rating: provider.culturalFit,
                onRatingChanged: provider.updateCulturalFit,
              ),

              const SizedBox(height: 20),

              _buildRatingSection(
                label: AppStrings.overallImpression,
                rating: provider.overallImpression,
                onRatingChanged: provider.updateOverallImpression,
              ),

              const SizedBox(height: 24),

              // Additional comments
              _buildCommentsSection(provider),

              const SizedBox(height: 24),

              // Overall score display
              _buildOverallScore(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormTitle() {
    return const Text(
      'Evaluation Criteria',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildRatingSection({
    required String label,
    required int rating,
    required ValueChanged<int> onRatingChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: LabeledStarRating(
        label: label,
        rating: rating,
        onRatingChanged: onRatingChanged,
      ),
    );
  }

  Widget _buildCommentsSection(EvaluationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.additionalComments,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: _commentsController,
            maxLines: 4,
            onChanged: provider.updateAdditionalComments,
            decoration: InputDecoration(
              hintText: AppStrings.commentsHint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildOverallScore(EvaluationProvider provider) {
    final score = provider.calculatedScore;
    final scorePercentage = (score * 10).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Overall Score',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          Text(
            '${score.toStringAsFixed(1)}/10 ($scorePercentage%)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
