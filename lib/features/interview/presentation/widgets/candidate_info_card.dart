import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Card widget displaying candidate information
class CandidateInfoCard extends StatelessWidget {
  final String candidateName;
  final String role;
  final String level;
  final DateTime interviewDate;

  const CandidateInfoCard({
    super.key,
    required this.candidateName,
    required this.role,
    required this.level,
    required this.interviewDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24), // Increased from 20 for better spacing
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
      child: _buildCandidateInfo(), // Remove Row wrapper, use info directly
    );
  }

  Widget _buildCandidateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center align content
      children: [
        // Candidate name (larger, more prominent)
        Text(
          candidateName,
          style: const TextStyle(
            fontSize: 22, // Increased from 18
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8), // Increased spacing
        // Role and level (more prominent)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$role - $level',
            style: TextStyle(
              fontSize: 16, // Increased from 14
              fontWeight: FontWeight.w600, // Increased weight
              color: AppColors.primary,
            ),
          ),
        ),

        const SizedBox(height: 12), // Increased spacing
        // Interview date (better styling)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                _formatDate(interviewDate),
                style: TextStyle(
                  fontSize: 13, // Slightly increased
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
