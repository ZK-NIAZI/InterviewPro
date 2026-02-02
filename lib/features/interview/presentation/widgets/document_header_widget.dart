import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Document header widget with InterviewPro logo and red divider
class DocumentHeaderWidget extends StatelessWidget {
  const DocumentHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo and brand
            Row(
              children: [
                Icon(Icons.fact_check, size: 32, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'InterviewPro',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),

            // Report type
            const Text(
              'INTERVIEW EVALUATION\nREPORT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Red divider line
        Container(height: 2, width: double.infinity, color: AppColors.primary),
      ],
    );
  }
}
