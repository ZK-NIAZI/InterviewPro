import 'package:flutter/material.dart';
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
    return Scaffold(
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
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    100,
                  ), // Bottom padding for fixed button
                  child: _buildRoleGrid(),
                ),
              ),
            ],
          ),

          // Fixed Bottom Button
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomButton()),
        ],
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
      color: Colors.white,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        0,
        8,
        0,
        32,
      ), // Added bottom padding for last row
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0, // Perfect square cards
        ),
        itemCount: roles.length,
        itemBuilder: (context, index) {
          return _buildRoleCard(index);
        },
      ),
    );
  }

  Widget _buildRoleCard(int index) {
    final role = roles[index];
    final isSelected = selectedRoleIndex == index;

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    role.icon,
                    size: 32,
                    color: isSelected ? AppColors.primary : Colors.black,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    role.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: selectedRoleIndex != null ? _onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              elevation: selectedRoleIndex != null ? 8 : 0,
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
    if (selectedRoleIndex == null) return;

    final selectedRoleName = roles[selectedRoleIndex!].title.replaceAll(
      '\n',
      ' ',
    );

    // Navigate to experience level selection
    context.push('${AppRouter.experienceLevel}?role=$selectedRoleName');
  }
}

/// Role option data class
class RoleOption {
  final String title;
  final IconData icon;

  RoleOption(this.title, this.icon);
}
