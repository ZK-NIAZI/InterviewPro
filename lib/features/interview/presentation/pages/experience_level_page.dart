import 'dart:ui';
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
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        _buildHeader(),

                        // Experience Level Cards
                        _buildLevelCards(),

                        // Extra spacing at the bottom to ensure last card is accessible
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Fixed Bottom Button
                _buildBottomButton(),
              ],
            ),
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
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 24,
                color: AppColors.primary,
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
    final bool hasSelection = selectedLevelIndex != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: hasSelection ? _onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasSelection
                  ? AppColors.primary
                  : Colors.grey[300],
              foregroundColor: hasSelection ? Colors.white : Colors.grey[600],
              elevation: hasSelection ? 8 : 0,
              shadowColor: hasSelection
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
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
    if (selectedLevelIndex == null) return;

    _showCandidateNameDialog();
  }

  /// Shows a modern, minimal dialog with blurred background for candidate name
  void _showCandidateNameDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.1),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Candidate Info',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please enter the name of the candidate to start the session.',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  textCapitalization: TextCapitalization.none,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Email (Recommended)',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Phone Number (Optional)',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    final candidateName = nameController.text.trim();
                    final candidateEmail = emailController.text.trim();
                    final candidatePhone = phoneController.text.trim();
                    Navigator.pop(context);

                    final levels = _experienceLevelProvider.experienceLevels;
                    final selectedLevelName = levels[selectedLevelIndex!].title;

                    // Use Uri to properly encode query parameters
                    final uri = Uri(
                      path: AppRouter.interviewQuestion,
                      queryParameters: {
                        'role': widget.selectedRole,
                        'level': selectedLevelName,
                        'candidateName': candidateName,
                        'candidateEmail': candidateEmail,
                        'candidatePhone': candidatePhone,
                      },
                    );

                    context.push(uri.toString());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text('Start Interview'),
              ),
            ],
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
      },
    );
  }
}

// Remove the old ExperienceLevel class as we now use the entity
