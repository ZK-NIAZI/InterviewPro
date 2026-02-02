import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Recommendation box widget with final verdict
class RecommendationBoxWidget extends StatelessWidget {
  final double overallScore;

  const RecommendationBoxWidget({super.key, required this.overallScore});

  @override
  Widget build(BuildContext context) {
    final isRecommended = overallScore >= 6.0;
    final verdict = isRecommended ? 'RECOMMENDED FOR HIRE' : 'NOT RECOMMENDED';

    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              'FINAL VERDICT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              verdict,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
