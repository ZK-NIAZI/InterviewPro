import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/domain/entities/entities.dart';
import '../../../../shared/presentation/widgets/premium_card.dart';
import '../providers/interview_setup_provider.dart';

/// Widget for selecting experience level with visual cards
class LevelSelectionWidget extends StatelessWidget {
  const LevelSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.selectLevel,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<InterviewSetupProvider>(
          builder: (context, provider, child) {
            return Row(
              children: [
                Expanded(
                  child: _buildLevelCard(
                    context,
                    level: Level.intern,
                    title: AppStrings.intern,
                    subtitle: 'Entry Level',
                    icon: Icons.school_rounded,
                    color: Colors.lightBlue,
                    isSelected: provider.selectedLevel == Level.intern,
                    onTap: () => provider.setSelectedLevel(Level.intern),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLevelCard(
                    context,
                    level: Level.associate,
                    title: AppStrings.associate,
                    subtitle: 'Mid Level',
                    icon: Icons.work_rounded,
                    color: Colors.amber,
                    isSelected: provider.selectedLevel == Level.associate,
                    onTap: () => provider.setSelectedLevel(Level.associate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLevelCard(
                    context,
                    level: Level.senior,
                    title: AppStrings.senior,
                    subtitle: 'Expert Level',
                    icon: Icons.star_rounded,
                    color: Colors.deepOrange,
                    isSelected: provider.selectedLevel == Level.senior,
                    onTap: () => provider.setSelectedLevel(Level.senior),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required Level level,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.white,
      border: Border.all(
        color: isSelected ? AppColors.primary : Colors.transparent,
        width: 2,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? AppColors.primary : color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
