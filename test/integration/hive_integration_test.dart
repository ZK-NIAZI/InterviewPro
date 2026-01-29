import 'package:flutter_test/flutter_test.dart';
import 'package:interview_pro_app/core/services/service_locator.dart';
import 'package:interview_pro_app/shared/data/services/hive_service.dart';
import 'package:interview_pro_app/shared/domain/entities/entities.dart';
import 'package:interview_pro_app/shared/domain/repositories/repositories.dart';

void main() {
  group('Hive Integration Tests', () {
    setUpAll(() async {
      await HiveService.init();
      await initializeDependencies();
    });

    tearDownAll(() async {
      await HiveService.clearAllData();
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

    test('should save and retrieve question through repository', () async {
      // Arrange
      final questionRepo = sl<QuestionRepository>();
      final question = Question(
        id: 'integration-q-1',
        text: 'Integration test question?',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: [Role.flutter],
        difficulty: Level.intern,
        tags: ['test'],
      );

      // Act
      await questionRepo.saveQuestion(question);
      final retrieved = await questionRepo.getQuestionById('integration-q-1');

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.text, equals('Integration test question?'));
      expect(
        retrieved.category,
        equals(QuestionCategory.programmingFundamentals),
      );
      expect(retrieved.applicableRoles, contains(Role.flutter));
    });

    test(
      'should filter questions by role and level through repository',
      () async {
        // Arrange
        final questionRepo = sl<QuestionRepository>();
        final questions = [
          Question(
            id: 'filter-q-1',
            text: 'Flutter intern question',
            category: QuestionCategory.programmingFundamentals,
            applicableRoles: [Role.flutter],
            difficulty: Level.intern,
            tags: ['flutter', 'intern'],
          ),
          Question(
            id: 'filter-q-2',
            text: 'Backend senior question',
            category: QuestionCategory.roleSpecificTechnical,
            applicableRoles: [Role.backend],
            difficulty: Level.senior,
            tags: ['backend', 'senior'],
          ),
        ];

        // Act
        await questionRepo.saveQuestions(questions);
        final flutterInternQuestions = await questionRepo
            .getQuestionsByRoleAndLevel(Role.flutter, Level.intern);

        // Assert
        expect(flutterInternQuestions.length, equals(1));
        expect(flutterInternQuestions.first.id, equals('filter-q-1'));
        expect(
          flutterInternQuestions.first.applicableRoles,
          contains(Role.flutter),
        );
        expect(flutterInternQuestions.first.difficulty, equals(Level.intern));
      },
    );
  });
}
