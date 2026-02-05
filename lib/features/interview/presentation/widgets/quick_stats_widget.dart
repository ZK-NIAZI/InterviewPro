import 'package:flutter/material.dart';

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
              child: _buildStatCard(
                icon: Icons.quiz_outlined,
                iconColor: Colors.blue,
                value: totalQuestions.toString(),
                label: 'Total Questions',
                backgroundColor: Colors.blue.withOpacity(0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle_outline,
                iconColor: Colors.green,
                value: correctAnswers.toString(),
                label: 'Correct Answers',
                backgroundColor: Colors.green.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required Color backgroundColor,
  }) {
    return Container(
      height: 80, // Fixed height to prevent overflow
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon and value in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
