import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/interview_question_provider.dart';

/// Widget for filtering interview questions
class QuestionFilterWidget extends StatelessWidget {
  const QuestionFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Consumer<InterviewQuestionProvider>(
                builder: (context, provider, child) {
                  final hasFilters =
                      provider.selectedCategory != null ||
                      provider.selectedDifficulty != null ||
                      provider.selectedRole != null ||
                      provider.selectedTags.isNotEmpty;

                  if (!hasFilters) return const SizedBox.shrink();

                  return TextButton(
                    onPressed: () => provider.clearFilters(),
                    child: const Text('Clear All'),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter chips
          Consumer<InterviewQuestionProvider>(
            builder: (context, provider, child) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Category filter
                    _buildFilterChip(
                      context,
                      label: 'Category',
                      value: provider.selectedCategory,
                      options: _getCategoryOptions(provider),
                      onSelected: (value) =>
                          provider.setSelectedCategory(value),
                    ),
                    const SizedBox(width: 8),

                    // Difficulty filter
                    _buildFilterChip(
                      context,
                      label: 'Difficulty',
                      value: provider.selectedDifficulty,
                      options: const ['beginner', 'intermediate', 'advanced'],
                      onSelected: (value) =>
                          provider.setSelectedDifficulty(value),
                    ),
                    const SizedBox(width: 8),

                    // Role filter
                    _buildFilterChip(
                      context,
                      label: 'Role',
                      value: provider.selectedRole,
                      options: _getRoleOptions(provider),
                      onSelected: (value) => provider.setSelectedRole(value),
                    ),
                  ],
                ),
              );
            },
          ),

          // Results count
          Consumer<InterviewQuestionProvider>(
            builder: (context, provider, child) {
              final count = provider.filteredQuestions.length;
              final total = provider.questions.length;

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Showing $count of $total questions',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onSelected,
  }) {
    return PopupMenuButton<String?>(
      itemBuilder: (context) => [
        PopupMenuItem<String?>(value: null, child: Text('All ${label}s')),
        ...options.map(
          (option) => PopupMenuItem<String?>(
            value: option,
            child: Text(_formatValue(option)),
          ),
        ),
      ],
      onSelected: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value != null
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value != null ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value != null ? '$label: ${_formatValue(value)}' : label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: value != null ? AppColors.primary : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: value != null ? AppColors.primary : Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(String value) {
    // Capitalize first letter and format display names
    switch (value.toLowerCase()) {
      case 'technical':
        return 'Technical Skills';
      case 'behavioral':
        return 'Behavioral & Soft Skills';
      case 'leadership':
        return 'Leadership & Management';
      case 'role-specific':
        return 'Role-Specific Questions';
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return value
            .split(' ')
            .map(
              (word) => word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : word,
            )
            .join(' ');
    }
  }

  List<String> _getCategoryOptions(InterviewQuestionProvider provider) {
    final categories = provider.categories.map((cat) => cat.id).toList();
    if (categories.isEmpty) {
      return ['technical', 'behavioral', 'leadership', 'role-specific'];
    }
    return categories;
  }

  List<String> _getRoleOptions(InterviewQuestionProvider provider) {
    final roles = provider.questions
        .where((q) => q.roleSpecific != null)
        .map((q) => q.roleSpecific!)
        .toSet()
        .toList();

    if (roles.isEmpty) {
      return ['Flutter Developer', 'Product Manager', 'UI/UX Designer'];
    }

    return roles;
  }
}
