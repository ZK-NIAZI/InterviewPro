import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/presentation/widgets/metric_card.dart';

/// Enhanced Quick Statistics widget with detailed interview metrics
class QuickStatsWidget extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final int? answeredQuestions;
  final double? completionPercentage;
  final int? duration;

  const QuickStatsWidget({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    this.answeredQuestions,
    this.completionPercentage,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row: Total questions and correct answers
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.quiz_outlined,
                value: totalQuestions.toString(),
                title: AppStrings.totalQuestions,
                center: true,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: Icons.check_circle_outline,
                value: correctAnswers.toString(),
                title: AppStrings.correctAnswers,
                center: true,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
