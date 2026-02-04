import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/report_data_provider.dart';

/// Widget displaying category performance with progress bars
class CategoryPerformanceWidget extends StatelessWidget {
  final List<CategoryPerformanceData> categories;

  const CategoryPerformanceWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: categories
          .map((category) => _buildCategoryItem(category))
          .toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No performance data available',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(CategoryPerformanceData category) {
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
                '${category.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getPerformanceColor(category.percentage),
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
                  color: _getPerformanceColor(category.percentage),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get color based on performance percentage
  Color _getPerformanceColor(double percentage) {
    if (percentage >= 80.0) {
      return Colors.green; // Excellent
    } else if (percentage >= 70.0) {
      return AppColors.primary; // Good
    } else if (percentage >= 50.0) {
      return Colors.orange; // Average
    } else {
      return Colors.red; // Poor
    }
  }
}
