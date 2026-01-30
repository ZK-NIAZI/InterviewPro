import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/interview/presentation/pages/interview_setup_page.dart';
import '../../features/interview/presentation/pages/experience_level_page.dart';

/// Application routing configuration
class AppRouter {
  // Route paths
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String interview = '/interview';
  static const String experienceLevel = '/experience-level';
  static const String questions = '/questions';
  static const String reports = '/reports';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: interview,
        name: 'interview',
        builder: (context, state) => const InterviewSetupPage(),
      ),
      GoRoute(
        path: experienceLevel,
        name: 'experience-level',
        builder: (context, state) {
          final selectedRole =
              state.uri.queryParameters['role'] ?? 'Flutter Developer';
          return ExperienceLevelPage(selectedRole: selectedRole);
        },
      ),
      //  Add other routes as features are implemented
    ],
  );
}
