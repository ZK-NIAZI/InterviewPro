import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../pages/interview_report_page.dart';

/// Widget displaying category performance with progress bars
class CategoryPerformanceWidget extends StatelessWidget {
  final List<CategoryData> categories;

  const CategoryPerformanceWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: categories
          .map((category) => _buildCategoryItem(category))
          .toList(),
    );
  }

  Widget _buildCategoryItem(CategoryData category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          // Category name and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${category.percentage.toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress bar
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: category.percentage / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
