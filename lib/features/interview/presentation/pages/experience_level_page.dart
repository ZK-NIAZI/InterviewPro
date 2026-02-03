import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../shared/domain/entities/experience_level.dart';
import '../providers/experience_level_provider.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../shared/domain/repositories/experience_level_repository.dart';

/// Experience level selection screen with Appwrite backend integration
class ExperienceLevelPage extends StatefulWidget {
  final String selectedRole;

  const ExperienceLevelPage({super.key, required this.selectedRole});

  @override
  State<ExperienceLevelPage> createState() => _ExperienceLevelPageState();
}

class _ExperienceLevelPageState extends State<ExperienceLevelPage> {
  int? selectedLevelIndex;
  late ExperienceLevelProvider _experienceLevelProvider;

  @override
  void initState() {
    super.initState();
    _experienceLevelProvider = ExperienceLevelProvider(
      sl<ExperienceLevelRepository>(),
    );
    // Load experience levels in background without blocking UI
    _experienceLevelProvider.loadExperienceLevelsInBackground();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _experienceLevelProvider,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Brightness.dark, // Black icons for light theme
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Safe area and header
                  SafeArea(child: _buildHeader()),

                  // Main Content: Cards Stack
                  Expanded(child: _buildLevelCards()),

                  // Bottom spacer for fixed button
                  const SizedBox(height: 100),
                ],
              ),

              // Fixed bottom button
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomButton(),
              ),
            ],
          ),
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
    return Consumer<ExperienceLevelProvider>(
      builder: (context, provider, child) {
        final levels = provider.experienceLevels;

        if (provider.isLoading && levels.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (levels.isEmpty) {
          return const Center(
            child: Text(
              'No experience levels available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

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
      },
    );
  }

  Widget _buildLevelCard(int index, ExperienceLevel level, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevelIndex = index;
        });
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

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    final levels = _experienceLevelProvider.experienceLevels;
    if (levels.isEmpty) return;

    // Use first level as default if no selection is made
    final selectedLevelName = selectedLevelIndex != null
        ? levels[selectedLevelIndex!].title
        : levels[0].title;

    // Navigate to interview question screen
    context.push(
      '${AppRouter.interviewQuestion}?role=${widget.selectedRole}&level=$selectedLevelName',
    );
  }
}

// Remove the old ExperienceLevel class as we now use the entity
