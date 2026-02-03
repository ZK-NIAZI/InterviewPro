import 'package:flutter/material.dart';

/// Simple and efficient Quick Statistics widget
class QuickStatsWidget extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;

  const QuickStatsWidget({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Total questions card
        Expanded(
          child: _buildSimpleStatCard(
            icon: Icons.quiz_outlined,
            iconColor: Colors.grey[600]!,
            value: totalQuestions.toString(),
            label: 'Total Questions',
          ),
        ),

        const SizedBox(width: 12),

        // Correct answers card
        Expanded(
          child: _buildSimpleStatCard(
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            value: correctAnswers.toString(),
            label: 'Correct Answers',
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      height: 80, // Fixed height to prevent overflow
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon and value in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
              color: Colors.grey[600],
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
