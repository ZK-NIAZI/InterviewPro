import 'package:flutter_test/flutter_test.dart';
import 'package:interview_pro_app/core/services/service_locator.dart';
import 'package:interview_pro_app/shared/data/services/hive_service.dart';
import 'package:interview_pro_app/shared/domain/entities/entities.dart';
import 'package:interview_pro_app/shared/domain/repositories/interview_question_repository.dart';
import 'package:interview_pro_app/shared/domain/repositories/interview_repository.dart';

import '../helpers/test_helper.dart';

void main() {
  group('Hive Integration Tests', () {
    setUpAll(() async {
      // Setup clean test environment
      await TestHelper.setupTest();

      await HiveService.init();
      await initializeDependencies();
    });

    tearDownAll(() async {
      await HiveService.clearAllData();
      await TestHelper.teardownTest();
    });

    setUp(() async {
      // Clear cache before each test to ensure isolation
      TestHelper.clearTestCaches();
    });

    test('should save and retrieve interview through repository', () async {
      // Arrange
      final interviewRepo = sl<InterviewRepository>();
      final interview = Interview(
        id: 'integration-test-1',
        candidateName: 'Integration Test User',
        role: Role.flutter,
        level: Level.associate,
        startTime: DateTime.now(),
        responses: [],
        status: InterviewStatus.notStarted,
      );

      // Act
      await interviewRepo.saveInterview(interview);
      final retrieved = await interviewRepo.getInterviewById(
        'integration-test-1',
      );

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.candidateName, equals('Integration Test User'));
      expect(retrieved.role, equals(Role.flutter));
      expect(retrieved.level, equals(Level.associate));
    });

    test(
      'should save and retrieve interview question through repository',
      () async {
        // Arrange
        final questionRepo = sl<InterviewQuestionRepository>();
        final question = InterviewQuestion(
          id: 'integration-q-1',
          question: 'Integration test question?',
          category: 'technical',
          difficulty: 'beginner',
          expectedDuration: 5,
          tags: ['test'],
          evaluationCriteria: ['Clear explanation'],
          roleSpecific: 'Flutter Developer',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await questionRepo.createQuestion(question);
        final questions = await questionRepo.getQuestions();
        final retrieved = questions.firstWhere(
          (q) => q.id == 'integration-q-1',
        );

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved.question, equals('Integration test question?'));
        expect(retrieved.category, equals('technical'));
        expect(retrieved.roleSpecific, equals('Flutter Developer'));
      },
    );

    test('should retrieve questions from repository', () async {
      // Arrange
      final questionRepo = sl<InterviewQuestionRepository>();

      // Act - Load questions (should initialize from JSON if empty)
      final hasQuestions = await questionRepo.hasQuestions();

      if (!hasQuestions) {
        await questionRepo.initializeDefaultQuestions();
      }

      final questions = await questionRepo.getQuestions();

      // Assert
      expect(questions, isNotEmpty);
      expect(questions.first.question, isNotEmpty);
      expect(questions.first.category, isNotEmpty);
    });
  });
}
