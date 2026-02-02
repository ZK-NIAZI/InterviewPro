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
      child: Row(
        children: [
          // Profile picture placeholder
          _buildProfilePicture(),

          const SizedBox(width: 16),

          // Candidate information
          Expanded(child: _buildCandidateInfo()),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Icon(Icons.person, size: 32, color: AppColors.primary),
    );
  }

  Widget _buildCandidateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Candidate name
        Text(
          candidateName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 4),

        // Role and level
        Text(
          '$role • $level',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),

        const SizedBox(height: 4),

        // Interview date
        Text(
          _formatDate(interviewDate),
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
