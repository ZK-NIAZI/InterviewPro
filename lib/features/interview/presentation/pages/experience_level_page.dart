import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

/// Experience level selection screen matching the provided HTML design
class ExperienceLevelPage extends StatefulWidget {
  final String selectedRole;

  const ExperienceLevelPage({super.key, required this.selectedRole});

  @override
  State<ExperienceLevelPage> createState() => _ExperienceLevelPageState();
}

class _ExperienceLevelPageState extends State<ExperienceLevelPage> {
  int? selectedLevelIndex;

  final List<ExperienceLevel> levels = [
    ExperienceLevel('Intern', '0-1 years experience, basic concepts'),
    ExperienceLevel('Associate', '1-3 years experience, solid fundamentals'),
    ExperienceLevel('Senior', '3+ years experience, advanced expertise'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Area
            _buildHeader(),

            // Main Content: Cards Stack
            Expanded(child: _buildLevelCards()),

            // Bottom Spacer
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 24,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Title and Subtitle
          const Text(
            'Select Experience Level',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'For ${widget.selectedRole} position',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: levels.asMap().entries.map((entry) {
          int index = entry.key;
          ExperienceLevel level = entry.value;
          bool isSelected = selectedLevelIndex == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildLevelCard(index, level, isSelected),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLevelCard(int index, ExperienceLevel level, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevelIndex = index;
        });

        // Show selection feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${level.title}'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border(left: BorderSide(color: AppColors.primary, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.15 : 0.04),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Right Icon
            if (isSelected)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.check, size: 20, color: Colors.white),
              )
            else
              const Icon(Icons.chevron_right, size: 24, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

/// Experience level data class
class ExperienceLevel {
  final String title;
  final String description;

  ExperienceLevel(this.title, this.description);
}
