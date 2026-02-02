import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_router.dart';

/// Role selection screen matching the provided HTML design exactly
class InterviewSetupPage extends StatefulWidget {
  const InterviewSetupPage({super.key});

  @override
  State<InterviewSetupPage> createState() => _InterviewSetupPageState();
}

class _InterviewSetupPageState extends State<InterviewSetupPage> {
  int? selectedRoleIndex;

  final List<RoleOption> roles = [
    RoleOption('Flutter\nDeveloper', Icons.smartphone),
    RoleOption('UI/UX\nDesigner', Icons.design_services),
    RoleOption('Product\nManager', Icons.business_center),
    RoleOption('Backend\nEngineer', Icons.dns),
    RoleOption('QA\nEngineer', Icons.bug_report),
    RoleOption('HR\nSpecialist', Icons.groups),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Black icons for light theme
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Header Section
                _buildHeader(),

                // Subtitle
                _buildSubtitle(),

                // Scrollable Content Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      // Dynamic bottom padding based on screen size
                      _calculateBottomPadding(context),
                    ),
                    child: _buildRoleGrid(),
                  ),
                ),
              ],
            ),

            // Fixed Bottom Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        8,
      ),
      color: Colors.white,
      child: Row(
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
                Icons.arrow_back,
                size: 24,
                color: Colors.black,
              ),
            ),
          ),

          // Title
          const Expanded(
            child: Text(
              'Select Role',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Spacer to balance the back button
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: const Text(
        'Choose the designation for this interview',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.grey,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRoleGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic spacing based on screen height and width
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        // Calculate available space more precisely
        final statusBarHeight = MediaQuery.of(context).padding.top;
        final headerHeight = statusBarHeight + 68;
        final subtitleHeight = 48;
        final buttonAreaHeight = 96;
        final paddingHeight = _calculateBottomPadding(context);

        final availableHeight =
            screenHeight -
            headerHeight -
            subtitleHeight -
            buttonAreaHeight -
            paddingHeight;

        // Adjust grid parameters based on available space
        final crossAxisSpacing = screenWidth > 400 ? 16.0 : 12.0;
        final mainAxisSpacing = availableHeight > 500 ? 16.0 : 12.0;

        // Calculate card aspect ratio to fit content properly
        final cardWidth =
            (screenWidth - 40 - crossAxisSpacing) /
            2; // Account for padding and spacing
        final cardHeight = availableHeight / 3.2; // Fit 3 rows comfortably
        final aspectRatio = cardWidth / cardHeight;

        // Ensure minimum aspect ratio for readability
        final finalAspectRatio = aspectRatio < 0.8
            ? 0.8
            : (aspectRatio > 1.2 ? 1.2 : aspectRatio);

        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: finalAspectRatio,
            ),
            itemCount: roles.length,
            itemBuilder: (context, index) {
              return _buildRoleCard(index);
            },
          ),
        );
      },
    );
  }

  Widget _buildRoleCard(int index) {
    final role = roles[index];
    final isSelected = selectedRoleIndex == index;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust icon and text sizes based on screen height
    final iconSize = screenHeight > 700 ? 32.0 : 28.0;
    final fontSize = screenHeight > 700 ? 16.0 : 14.0;
    final spacing = screenHeight > 700 ? 12.0 : 8.0;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRoleIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content - perfectly centered
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      role.icon,
                      size: iconSize,
                      color: isSelected ? AppColors.primary : Colors.black,
                    ),
                    SizedBox(height: spacing),
                    Flexible(
                      child: Text(
                        role.title,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Selected checkmark badge
            if (isSelected)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    final isRoleSelected = selectedRoleIndex != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isRoleSelected ? _onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isRoleSelected
                  ? AppColors.primary
                  : Colors.grey[300],
              foregroundColor: isRoleSelected ? Colors.white : Colors.grey[500],
              elevation: isRoleSelected ? 2 : 0,
              shadowColor: isRoleSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // Disable button interaction when no role is selected
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[500],
            ),
            child: Text(
              isRoleSelected ? 'Continue' : 'Select a Role to Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isRoleSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    // Double-check validation - this should never be called without selection
    if (selectedRoleIndex == null) {
      return; // Button should be disabled, but extra safety check
    }

    final selectedRoleName = roles[selectedRoleIndex!].title.replaceAll(
      '\n',
      ' ',
    );

    // Navigate to experience level selection
    context.push('${AppRouter.experienceLevel}?role=$selectedRoleName');
  }

  /// Calculate dynamic bottom padding based on screen size and available space
  double _calculateBottomPadding(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Account for status bar, header, subtitle, and button area
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = statusBarHeight + 68; // Header container height
    final subtitleHeight = 48; // Subtitle area height
    final buttonAreaHeight = 96; // Button container + safe area

    final availableHeight =
        screenHeight - headerHeight - subtitleHeight - buttonAreaHeight;

    // Calculate required height for 3 rows of cards (6 cards total)
    final cardHeight = (screenWidth - 56) / 2 * 0.9; // Card aspect ratio 0.9
    final requiredGridHeight = (cardHeight * 3) + (16 * 2); // 3 rows + spacing

    // If available space is tight, increase bottom padding
    if (availableHeight < requiredGridHeight + 40) {
      return 140; // Extra padding for smaller screens
    } else if (screenHeight < 700) {
      return 120; // Medium padding for medium screens
    } else {
      return 100; // Standard padding for larger screens
    }
  }
}

/// Role option data class
class RoleOption {
  final String title;
  final IconData icon;

  RoleOption(this.title, this.icon);
}
