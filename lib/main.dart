import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/services/service_locator.dart';
import 'features/splash/presentation/providers/splash_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/interview/presentation/providers/interview_setup_provider.dart';
import 'shared/data/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await HiveService.init();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const InterviewProApp());
}

class InterviewProApp extends StatelessWidget {
  const InterviewProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider(sl())),
        ChangeNotifierProvider(
          create: (_) => InterviewSetupProvider(sl(), sl()),
        ),
      ],
      child: MaterialApp.router(
        title: 'InterviewPro',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
