import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating sections
            _buildRatingSection(
              label: AppStrings.communicationSkills,
              rating: provider.communicationSkills,
              onRatingChanged: provider.updateCommunicationSkills,
            ),

            const SizedBox(height: 32),

            _buildRatingSection(
              label: AppStrings.problemSolvingApproach,
              rating: provider.problemSolvingApproach,
              onRatingChanged: provider.updateProblemSolvingApproach,
            ),

            const SizedBox(height: 32),

            _buildRatingSection(
              label: AppStrings.culturalFit,
              rating: provider.culturalFit,
              onRatingChanged: provider.updateCulturalFit,
            ),

            const SizedBox(height: 32),

            _buildRatingSection(
              label: AppStrings.overallImpression,
              rating: provider.overallImpression,
              onRatingChanged: provider.updateOverallImpression,
            ),

            const SizedBox(height: 40),

            // Additional comments
            _buildCommentsSection(provider),
          ],
        );
      },
    );
  }

  Widget _buildRatingSection({
    required String label,
    required int rating,
    required ValueChanged<int> onRatingChanged,
  }) {
    return LabeledStarRating(
      label: label,
      rating: rating,
      onRatingChanged: onRatingChanged,
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

        const SizedBox(height: 12),

        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: _commentsController,
            maxLines: null,
            expands: true,
            onChanged: provider.updateAdditionalComments,
            decoration: InputDecoration(
              hintText: 'Write your observation here...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black),
            textAlignVertical: TextAlignVertical.top,
          ),
        ),
      ],
    );
  }
}
