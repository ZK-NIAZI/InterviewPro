import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/presentation/widgets/premium_card.dart';
import '../providers/dashboard_provider.dart';

/// Widget displaying interview statistics and summary information
class InterviewStatsWidget extends StatelessWidget {
  const InterviewStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interview Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            return PremiumCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Total Interviews',
                          provider.totalInterviews.toString(),
                          Icons.quiz_rounded,
                          AppColors.primary,
                        ),
                      ),
                      Container(width: 1, height: 40, color: AppColors.grey300),
                      Expanded(
                        child: _buildStatItem(
                          'Completed',
                          provider.completedInterviews.toString(),
                          Icons.check_circle_rounded,
                          AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: AppColors.grey300),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'In Progress',
                          provider.inProgressInterviews.toString(),
                          Icons.pending_rounded,
                          AppColors.warning,
                        ),
                      ),
                      Container(width: 1, height: 40, color: AppColors.grey300),
                      Expanded(
                        child: _buildStatItem(
                          'This Week',
                          provider.thisWeekInterviews.toString(),
                          Icons.calendar_today_rounded,
                          AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
