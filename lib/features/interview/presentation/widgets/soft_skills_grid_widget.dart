import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Soft skills grid widget with star ratings
class SoftSkillsGridWidget extends StatelessWidget {
  final int communicationSkills;
  final int problemSolvingApproach;
  final int culturalFit;
  final int overallImpression;

  const SoftSkillsGridWidget({
    super.key,
    required this.communicationSkills,
    required this.problemSolvingApproach,
    required this.culturalFit,
    required this.overallImpression,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: const Text(
            'SOFT SKILLS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildSkillItem('Communication Skills', communicationSkills),
                  const SizedBox(height: 16),
                  _buildSkillItem('Cultural Fit', culturalFit),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _buildSkillItem(
                    'Problem-Solving Approach',
                    problemSolvingApproach,
                  ),
                  const SizedBox(height: 16),
                  _buildSkillItem('Overall Impression', overallImpression),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillItem(String label, int rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (index) {
            final isActive = index < rating;
            return Icon(
              Icons.star,
              size: 18,
              color: isActive ? AppColors.primary : const Color(0xFFD1D5DB),
            );
          }),
        ),
      ],
    );
  }
}
