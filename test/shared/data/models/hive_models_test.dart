import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:interview_pro_app/shared/data/models/models.dart';
import 'package:interview_pro_app/shared/domain/entities/entities.dart';

void main() {
  group('Hive Models', () {
    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('./test/hive_test');

      // Register adapters
      Hive.registerAdapter(RoleAdapter());
      Hive.registerAdapter(LevelAdapter());
      Hive.registerAdapter(QuestionCategoryAdapter());
      Hive.registerAdapter(InterviewStatusAdapter());
      Hive.registerAdapter(InterviewModelAdapter());
      Hive.registerAdapter(QuestionModelAdapter());
      Hive.registerAdapter(QuestionResponseModelAdapter());
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    test('InterviewModel should convert to and from entity correctly', () {
      // Arrange
      final interview = Interview(
        id: 'test-1',
        candidateName: 'John Doe',
        role: Role.flutter,
        level: Level.associate,
        startTime: DateTime(2024, 1, 1, 10, 0),
        responses: [
          QuestionResponse(
            questionId: 'q-1',
            isCorrect: true,
            notes: 'Good answer',
            timestamp: DateTime(2024, 1, 1, 10, 5),
          ),
        ],
        status: InterviewStatus.inProgress,
        overallScore: 85.5,
      );

      // Act
      final model = InterviewModel.fromEntity(interview);
      final convertedBack = model.toEntity();

      // Assert
      expect(convertedBack.id, equals(interview.id));
      expect(convertedBack.candidateName, equals(interview.candidateName));
      expect(convertedBack.role, equals(interview.role));
      expect(convertedBack.level, equals(interview.level));
      expect(convertedBack.startTime, equals(interview.startTime));
      expect(
        convertedBack.responses.length,
        equals(interview.responses.length),
      );
      expect(convertedBack.status, equals(interview.status));
      expect(convertedBack.overallScore, equals(interview.overallScore));
    });

    test('QuestionModel should convert to and from entity correctly', () {
      // Arrange
      final question = Question(
        id: 'q-1',
        text: 'What is Flutter?',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: [Role.flutter, Role.mobile],
        difficulty: Level.intern,
        expectedAnswer: 'Flutter is a UI toolkit',
        tags: ['flutter', 'basics'],
      );

      // Act
      final model = QuestionModel.fromEntity(question);
      final convertedBack = model.toEntity();

      // Assert
      expect(convertedBack.id, equals(question.id));
      expect(convertedBack.text, equals(question.text));
      expect(convertedBack.category, equals(question.category));
      expect(convertedBack.applicableRoles, equals(question.applicableRoles));
      expect(convertedBack.difficulty, equals(question.difficulty));
      expect(convertedBack.expectedAnswer, equals(question.expectedAnswer));
      expect(convertedBack.tags, equals(question.tags));
    });

    test(
      'QuestionResponseModel should convert to and from entity correctly',
      () {
        // Arrange
        final response = QuestionResponse(
          questionId: 'q-1',
          isCorrect: true,
          notes: 'Excellent answer',
          timestamp: DateTime(2024, 1, 1, 10, 5),
        );

        // Act
        final model = QuestionResponseModel.fromEntity(response);
        final convertedBack = model.toEntity();

        // Assert
        expect(convertedBack.questionId, equals(response.questionId));
        expect(convertedBack.isCorrect, equals(response.isCorrect));
        expect(convertedBack.notes, equals(response.notes));
        expect(convertedBack.timestamp, equals(response.timestamp));
      },
    );

    test('Enum adapters should work correctly', () async {
      // Arrange
      final box = await Hive.openBox<Role>('test_roles');

      // Act
      await box.put('role1', Role.flutter);
      await box.put('role2', Role.backend);

      final retrievedRole1 = box.get('role1');
      final retrievedRole2 = box.get('role2');

      // Assert
      expect(retrievedRole1, equals(Role.flutter));
      expect(retrievedRole2, equals(Role.backend));

      // Cleanup
      await box.close();
    });
  });
}
