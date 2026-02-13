import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Recommendation box widget with final verdict
class RecommendationBoxWidget extends StatelessWidget {
  final double overallScore;
  final String? recommendation;

  const RecommendationBoxWidget({
    super.key,
    required this.overallScore,
    this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    // Standardize threshold to 70% as per app requirements
    final isRecommended = overallScore >= 70.0;
    final verdict =
        recommendation?.toUpperCase() ??
        (isRecommended ? 'RECOMMENDED FOR HIRE' : 'NOT RECOMMENDED');

    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              'FINAL VERDICT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 0, 0),
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              verdict,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
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
