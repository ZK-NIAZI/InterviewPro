import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:interview_pro_app/features/splash/presentation/pages/splash_page.dart';
import 'package:interview_pro_app/features/splash/presentation/providers/splash_provider.dart';
import 'package:interview_pro_app/core/constants/app_colors.dart';
import 'package:interview_pro_app/core/constants/app_strings.dart';

void main() {
  group('Splash Screen Tests', () {
    testWidgets('should display InterviewPro branding with correct colors', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => SplashProvider(),
            child: const SplashPage(),
          ),
        ),
      );

      // Act & Assert
      // Verify InterviewPro text is displayed
      expect(find.text(AppStrings.appName), findsOneWidget);

      // Verify mic icon is displayed
      expect(find.byIcon(Icons.mic), findsOneWidget);

      // Verify primary color is used for branding elements
      final Container logoContainer = tester.widget(
        find.byType(Container).first,
      );
      expect(
        (logoContainer.decoration as BoxDecoration).color,
        AppColors.primary,
      );
    });

    testWidgets('should show loading animation components', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => SplashProvider(),
            child: const SplashPage(),
          ),
        ),
      );

      // Act & Assert
      // Verify animation components are present
      expect(find.byType(AnimatedBuilder), findsWidgets);
      expect(find.byType(FadeTransition), findsWidgets);
    });

    testWidgets('should have proper layout structure', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => SplashProvider(),
            child: const SplashPage(),
          ),
        ),
      );

      // Act & Assert
      // Verify scaffold background color
      final Scaffold scaffold = tester.widget(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.backgroundLight);

      // Verify main column structure
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Expanded), findsWidgets);
    });
  });
}
