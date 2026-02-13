import 'package:flutter/material.dart';
import 'package:interview_pro_app/core/constants/app_colors.dart';

/// Candidate information box widget with grid layout
class CandidateInfoBoxWidget extends StatelessWidget {
  final String candidateName;
  final String role;
  final String level;
  final String date;

  const CandidateInfoBoxWidget({
    super.key,
    required this.candidateName,
    required this.role,
    required this.level,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInfoItem('CANDIDATE NAME', candidateName)),
              Expanded(child: _buildInfoItem('POSITION', role)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoItem('LEVEL', level)),
              Expanded(child: _buildInfoItem('DATE', date)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 0, 0, 0),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ],
    );
  }
}
