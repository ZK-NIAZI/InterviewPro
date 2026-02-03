import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../shared/domain/entities/role.dart';
import '../providers/role_provider.dart';

/// Role selection screen with dynamic roles from Appwrite backend
class InterviewSetupPage extends StatefulWidget {
  const InterviewSetupPage({super.key});

  @override
  State<InterviewSetupPage> createState() => _InterviewSetupPageState();
}

class _InterviewSetupPageState extends State<InterviewSetupPage> {
  @override
  void initState() {
    super.initState();
    // Load roles when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoleProvider>().loadRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Consumer<RoleProvider>(
          builder: (context, roleProvider, child) {
            return Stack(
              children: [
                // Main content
                Column(
                  children: [
                    // Header Section
                    _buildHeader(),

                    // Content Area
                    Expanded(child: _buildContent(roleProvider)),
                  ],
                ),

                // Fixed Bottom Button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomButton(roleProvider),
                ),
              ],
            );
          },
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

  Widget _buildContent(RoleProvider roleProvider) {
    if (roleProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading roles...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (roleProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load roles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                roleProvider.error!,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => roleProvider.refreshRoles(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (roleProvider.roles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No roles available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, _calculateBottomPadding(context)),
      child: _buildRoleGrid(roleProvider.roles),
    );
  }

  Widget _buildRoleGrid(List<Role> roles) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic spacing based on screen height and width
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        // Calculate available space more precisely
        final statusBarHeight = MediaQuery.of(context).padding.top;
        final headerHeight = statusBarHeight + 68;
        final buttonAreaHeight = 96;
        final paddingHeight = _calculateBottomPadding(context);

        final availableHeight =
            screenHeight - headerHeight - buttonAreaHeight - paddingHeight;

        // Adjust grid parameters based on available space
        final crossAxisSpacing = screenWidth > 400 ? 16.0 : 12.0;
        final mainAxisSpacing = availableHeight > 500 ? 16.0 : 12.0;

        // Calculate card aspect ratio to fit content properly
        final cardWidth = (screenWidth - 40 - crossAxisSpacing) / 2;
        final cardHeight = availableHeight / 3.2;
        final aspectRatio = cardWidth / cardHeight;

        // Ensure minimum aspect ratio for readability
        final finalAspectRatio = aspectRatio < 0.8
            ? 0.8
            : (aspectRatio > 1.2 ? 1.2 : aspectRatio);

        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
              return _buildRoleCard(roles[index], index);
            },
          ),
        );
      },
    );
  }

  Widget _buildRoleCard(Role role, int index) {
    final roleProvider = context.watch<RoleProvider>();
    final isSelected = roleProvider.selectedRoleId == role.id;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust icon and text sizes based on screen height
    final iconSize = screenHeight > 700 ? 32.0 : 28.0;
    final fontSize = screenHeight > 700 ? 16.0 : 14.0;
    final spacing = screenHeight > 700 ? 12.0 : 8.0;

    // Map icon names to IconData
    final iconData = _getIconData(role.icon);

    return GestureDetector(
      onTap: () {
        roleProvider.selectRole(role.id);
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
                      iconData,
                      size: iconSize,
                      color: isSelected ? AppColors.primary : Colors.black,
                    ),
                    SizedBox(height: spacing),
                    Flexible(
                      child: Text(
                        role.name,
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

  Widget _buildBottomButton(RoleProvider roleProvider) {
    final isRoleSelected = roleProvider.selectedRoleId != null;

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
            onPressed: isRoleSelected ? () => _onContinue(roleProvider) : null,
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

  void _onContinue(RoleProvider roleProvider) {
    if (roleProvider.selectedRole == null) {
      return;
    }

    final selectedRole = roleProvider.selectedRole!;

    // Navigate to experience level selection
    context.push('${AppRouter.experienceLevel}?role=${selectedRole.name}');
  }

  /// Calculate dynamic bottom padding based on screen size and available space
  double _calculateBottomPadding(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Account for status bar, header, and button area (subtitle removed)
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = statusBarHeight + 68;
    final buttonAreaHeight = 96;

    final availableHeight = screenHeight - headerHeight - buttonAreaHeight;

    // Calculate required height for 3 rows of cards
    final cardHeight = (screenWidth - 56) / 2 * 0.9;
    final requiredGridHeight = (cardHeight * 3) + (16 * 2);

    // If available space is tight, increase bottom padding
    if (availableHeight < requiredGridHeight + 40) {
      return 140;
    } else if (screenHeight < 700) {
      return 120;
    } else {
      return 100;
    }
  }

  /// Map icon string to IconData
  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'flutter':
      case 'smartphone':
        return Icons.smartphone;
      case 'design_services':
        return Icons.design_services;
      case 'business_center':
        return Icons.business_center;
      case 'storage':
      case 'dns':
        return Icons.dns;
      case 'bug_report':
        return Icons.bug_report;
      case 'people':
      case 'groups':
        return Icons.groups;
      default:
        return Icons.work;
    }
  }
}
