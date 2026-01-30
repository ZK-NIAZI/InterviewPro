import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// History content widget that displays interview history within the dashboard
class HistoryContentWidget extends StatefulWidget {
  const HistoryContentWidget({super.key});

  @override
  State<HistoryContentWidget> createState() => _HistoryContentWidgetState();
}

class _HistoryContentWidgetState extends State<HistoryContentWidget> {
  // Selected filter index (0 = All, 1 = This Week, 2 = This Month)
  int selectedFilterIndex = 0;

  // Filter options
  final List<String> filterOptions = ['All', 'This Week', 'This Month'];

  // Mock interview data matching the HTML design
  final List<InterviewHistoryItem> interviews = [
    InterviewHistoryItem(
      name: 'Sarah Jenkins',
      position: 'UX Designer',
      date: 'Oct 24',
      score: 9.2,
      statusColor: Colors.green,
    ),
    InterviewHistoryItem(
      name: 'Mike Ross',
      position: 'Legal Consultant',
      date: 'Oct 22',
      score: 4.5,
      statusColor: AppColors.primary,
    ),
    InterviewHistoryItem(
      name: 'Jessica Pearson',
      position: 'Managing Partner',
      date: 'Oct 20',
      score: null, // No score yet
      statusColor: Colors.grey,
    ),
    InterviewHistoryItem(
      name: 'Louis Litt',
      position: 'Financial Analyst',
      date: 'Oct 19',
      score: 8.8,
      statusColor: Colors.green,
    ),
    InterviewHistoryItem(
      name: 'Donna Paulsen',
      position: 'Office Manager',
      date: 'Oct 18',
      score: 9.9,
      statusColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F6F6), // Background light color from HTML
      child: Column(
        children: [
          // Filter chips section
          _buildFilterChips(),

          // Stats carousel section
          _buildStatsCarousel(),

          // Interview list section
          Expanded(child: _buildInterviewList()),
        ],
      ),
    );
  }

  /// Builds the filter chips (All, This Week, This Month)
  Widget _buildFilterChips() {
    return Container(
      color: const Color(0xFFF8F6F6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filterOptions.asMap().entries.map((entry) {
            int index = entry.key;
            String option = entry.value;
            bool isSelected = selectedFilterIndex == index;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFilterIndex = index;
                  });
                },
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFF3E8E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Builds the stats carousel with Total Interviews, Avg Score, Hired
  Widget _buildStatsCarousel() {
    return Container(
      color: const Color(0xFFF8F6F6),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildStatCard('Total Interviews', '24'),
            const SizedBox(width: 16),
            _buildStatCard('Avg Score', '8.5'),
            const SizedBox(width: 16),
            _buildStatCard('Hired', '6'),
          ],
        ),
      ),
    );
  }

  /// Builds individual stat card
  Widget _buildStatCard(String title, String value) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE6D0D2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the scrollable interview list
  Widget _buildInterviewList() {
    return Container(
      color: const Color(0xFFF8F6F6),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: interviews.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInterviewListItem(interviews[index]),
          );
        },
      ),
    );
  }

  /// Builds individual interview list item
  Widget _buildInterviewListItem(InterviewHistoryItem interview) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left colored indicator
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: interview.statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(width: 12),

          // Interview details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interview.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      interview.position,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const Text(
                      ' • ',
                      style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                    ),
                    Text(
                      interview.date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Score badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: interview.score != null
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              interview.score?.toString() ?? '--',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: interview.score != null
                    ? AppColors.primary
                    : const Color(0xFF999999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class for interview history items
class InterviewHistoryItem {
  final String name;
  final String position;
  final String date;
  final double? score;
  final Color statusColor;

  InterviewHistoryItem({
    required this.name,
    required this.position,
    required this.date,
    this.score,
    required this.statusColor,
  });
}
