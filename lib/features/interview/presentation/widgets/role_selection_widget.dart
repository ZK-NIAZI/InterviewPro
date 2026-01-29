import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/domain/entities/entities.dart';
import '../providers/interview_setup_provider.dart';

/// Widget for selecting developer role with visual cards
class RoleSelectionWidget extends StatelessWidget {
  const RoleSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.selectRole,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<InterviewSetupProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleCard(
                        context,
                        role: Role.flutter,
                        title: AppStrings.flutterDeveloper,
                        icon: Icons.flutter_dash,
                        color: Colors.blue,
                        isSelected: provider.selectedRole == Role.flutter,
                        onTap: () => provider.setSelectedRole(Role.flutter),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRoleCard(
                        context,
                        role: Role.backend,
                        title: AppStrings.backendDeveloper,
                        icon: Icons.storage_rounded,
                        color: Colors.green,
                        isSelected: provider.selectedRole == Role.backend,
                        onTap: () => provider.setSelectedRole(Role.backend),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleCard(
                        context,
                        role: Role.frontend,
                        title: AppStrings.frontendDeveloper,
                        icon: Icons.web_rounded,
                        color: Colors.orange,
                        isSelected: provider.selectedRole == Role.frontend,
                        onTap: () => provider.setSelectedRole(Role.frontend),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRoleCard(
                        context,
                        role: Role.fullStack,
                        title: AppStrings.fullStackDeveloper,
                        icon: Icons.layers_rounded,
                        color: Colors.purple,
                        isSelected: provider.selectedRole == Role.fullStack,
                        onTap: () => provider.setSelectedRole(Role.fullStack),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleCard(
                        context,
                        role: Role.mobile,
                        title: AppStrings.mobileDeveloper,
                        icon: Icons.phone_android_rounded,
                        color: Colors.teal,
                        isSelected: provider.selectedRole == Role.mobile,
                        onTap: () => provider.setSelectedRole(Role.mobile),
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ), // Empty space for alignment
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required Role role,
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? AppColors.primary : color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
