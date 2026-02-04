import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_router.dart';
import '../providers/dashboard_provider.dart';
import '../../../history/presentation/widgets/history_content_widget.dart';
import '../../../settings/presentation/widgets/settings_content_widget.dart';

/// Main dashboard page matching the provided HTML design exactly
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load dashboard data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

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
        backgroundColor: _selectedIndex == 1
            ? const Color(0xFFF8F6F6) // History background
            : _selectedIndex == 2
            ? const Color(0xFFF8F6F6) // Settings background
            : AppColors.backgroundLight, // Home background
        body: Column(
          children: [
            // Header - changes based on selected tab
            _buildHeader(),

            // Main Content - changes based on selected tab
            Expanded(child: _buildMainContent()),
          ],
        ),

        // Bottom Navigation - always visible
        bottomNavigationBar: _buildBottomNavigation(),

        // Floating Action Button - only show on history tab
        floatingActionButton: _selectedIndex == 1
            ? _buildFloatingActionButton()
            : null,
      ),
    );
  }

  Widget _buildHeader() {
    // Different headers based on selected tab
    switch (_selectedIndex) {
      case 1: // History tab
        return _buildHistoryHeader();
      case 2: // Settings tab
        return _buildSettingsHeader();
      default: // Home tab
        return _buildHomeHeader();
    }
  }

  Widget _buildHomeHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withValues(alpha: 0.9),
        border: Border(bottom: BorderSide(color: AppColors.grey200, width: 1)),
      ),
      child: Row(
        children: [
          // Logo and Title
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Debug: Config Test Button (removed - use Appwrite console)
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Use Appwrite console to manage configuration'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.settings_applications),
            tooltip: 'Appwrite Console',
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Container(
      color: const Color(0xFFF8F6F6),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          const Text(
            'Interview History',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),

          // Search button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: IconButton(
              onPressed: () {
                // Search functionality - show search dialog
                _showSearchDialog();
              },
              icon: const Icon(Icons.search, size: 28, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withValues(alpha: 0.9),
        border: Border(bottom: BorderSide(color: AppColors.grey200, width: 1)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the settings text
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    // Different content based on selected tab
    switch (_selectedIndex) {
      case 1: // History tab
        return const HistoryContentWidget();
      case 2: // Settings tab
        return _buildSettingsContent();
      default: // Home tab
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        // Static content section
        Container(
          color: AppColors.backgroundLight,
          child: Column(
            children: [
              // Hero Action Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: _buildStartInterviewButton(),
              ),
              const SizedBox(height: 32),

              // Stats Overview
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStatsSection(),
              ),
              const SizedBox(height: 32),

              // Recent Interviews Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Interviews',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedIndex = 1);
                      },
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Scrollable content section (only candidate cards)
        Expanded(child: _buildScrollableInterviewCards()),
      ],
    );
  }

  Widget _buildSettingsContent() {
    return const SettingsContentWidget();
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          // Navigate to start new interview
          context.push(AppRouter.interview);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  Widget _buildStartInterviewButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => context.push(AppRouter.interview),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Start New Interview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: Selector<DashboardProvider, int>(
            selector: (context, provider) => provider.thisWeekInterviews,
            builder: (context, thisWeekInterviews, child) =>
                _buildStatCard('THIS WEEK', thisWeekInterviews.toString()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Selector<DashboardProvider, double>(
            selector: (context, provider) => provider.averageScore,
            builder: (context, averageScore, child) =>
                _buildStatCard('AVG SCORE', averageScore.toStringAsFixed(1)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableInterviewCards() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // Mock data to match the design
        final mockInterviews = [
          _MockInterview(
            'Sarah Jenkins',
            'Senior Product Designer - L4',
            'Oct 24, 2023',
            4.5,
          ),
          _MockInterview(
            'Michael Chen',
            'Backend Engineer - L3',
            'Oct 22, 2023',
            3.8,
          ),
          _MockInterview(
            'Jessica Alverez',
            'Product Manager - L5',
            'Oct 20, 2023',
            4.8,
          ),
          _MockInterview(
            'David Kim',
            'Frontend Developer - L3',
            'Oct 18, 2023',
            null,
          ),
          _MockInterview(
            'Emily Rodriguez',
            'UI/UX Designer - L2',
            'Oct 16, 2023',
            4.2,
          ),
          _MockInterview(
            'James Wilson',
            'Full Stack Developer - L4',
            'Oct 14, 2023',
            3.9,
          ),
        ];

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            100,
          ), // Bottom padding for nav
          itemCount: mockInterviews.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildInterviewCard(mockInterviews[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildInterviewCard(_MockInterview interview) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interview.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  interview.position,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      interview.date,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Score and Arrow
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: interview.score != null
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.grey200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  interview.score?.toString() ?? '–',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: interview.score != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.chevron_right, color: AppColors.grey400, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.grey200, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
            ),
            _buildNavItem(
              icon: Icons.history,
              label: 'History',
              isSelected: _selectedIndex == 1,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            _buildNavItem(
              icon: Icons.settings,
              label: 'Settings',
              isSelected: _selectedIndex == 2,
              onTap: () => setState(() => _selectedIndex = 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? AppColors.primary : AppColors.grey400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.grey400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows search dialog
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Interviews'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Search by candidate name...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // Search functionality can be implemented here
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Search action can be implemented here
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}

// Mock interview class for demonstration
class _MockInterview {
  final String name;
  final String position;
  final String date;
  final double? score;

  _MockInterview(this.name, this.position, this.date, this.score);
}
