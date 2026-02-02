import 'package:flutter/material.dart';

/// Widget displaying quick statistics in a grid layout
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
          child: _buildStatCard(
            icon: Icons.quiz,
            iconColor: Colors.grey[500]!,
            value: totalQuestions.toString(),
            label: 'Total Questions',
          ),
        ),

        const SizedBox(width: 16),

        // Correct answers card
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            iconColor: Colors.green[600]!,
            value: correctAnswers.toString(),
            label: 'Correct Answers',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),

          const SizedBox(height: 8),

          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
