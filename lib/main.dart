import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/services/service_locator.dart';
import 'features/splash/presentation/providers/splash_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/history/presentation/providers/history_provider.dart';
import 'features/interview/presentation/providers/interview_setup_provider.dart';
import 'features/interview/presentation/providers/evaluation_provider.dart';
import 'features/interview/presentation/providers/role_provider.dart';
import 'features/interview/presentation/providers/interview_question_provider.dart';
import 'features/interview/presentation/providers/report_data_provider.dart';
import 'features/interview/presentation/providers/voice_recording_provider.dart';

import 'dart:async';
import 'core/services/crash_reporting_service.dart';

void main() async {
  // Catch errors strictly outside of Flutter context
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Crash Reporting
      final crashReporter = CrashReportingService();
      await crashReporter.init();

      // Pass all uncaught Flutter errors to CrashReportingService
      FlutterError.onError = crashReporter.handleFlutterError;

      // Set global status bar style for light theme
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Brightness.dark, // Black icons for light theme
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      // Initialize dependencies with error handling (CRASH FIX)
      try {
        await initializeDependencies();
        debugPrint('✅ Dependencies initialized successfully');
      } catch (e, stack) {
        debugPrint('⚠️ Failed to initialize dependencies: $e');
        crashReporter.recordError(
          e,
          stack,
          reason: 'Dependency Initialization Failed',
        );
        // Continue with app launch - some features may not work but app won't crash
      }

      runApp(const InterviewProApp());
    },
    (error, stack) {
      // Catch global async errors
      CrashReportingService().recordError(
        error,
        stack,
        reason: 'Uncaught Global Error',
      );
    },
  );
}

class InterviewProApp extends StatelessWidget {
  const InterviewProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider(sl())),
        ChangeNotifierProvider(create: (_) => HistoryProvider(sl())),
        ChangeNotifierProvider(
          create: (_) => InterviewSetupProvider(sl(), sl()),
        ),
        ChangeNotifierProvider(create: (_) => EvaluationProvider(sl())),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => InterviewQuestionProvider(sl())),
        ChangeNotifierProvider(create: (_) => ReportDataProvider(sl())),
        ChangeNotifierProvider(create: (_) => VoiceRecordingProvider(sl())),
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
