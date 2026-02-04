import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:interview_pro_app/shared/domain/entities/entities.dart';
import 'package:interview_pro_app/shared/data/models/models.dart';

import '../helpers/test_helper.dart';
import '../helpers/platform_mock_helper.dart';

void main() {
  group('Hive Integration Tests', () {
    setUpAll(() async {
      // Setup platform mocks for file system operations
      PlatformMockHelper.setupMocks();

      // Initialize Hive with test directory (in-memory)
      Hive.init('./test/temp');

      // Register only the adapters we need for testing
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(RoleAdapter());
      }
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(LevelAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(QuestionCategoryAdapter());
      }
      if (!Hive.isAdapterRegistered(13)) {
        Hive.registerAdapter(InterviewStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(InterviewModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(QuestionResponseModelAdapter());
      }
    });

    tearDownAll(() async {
      // Clean up Hive
      await Hive.deleteFromDisk();

      // Teardown platform mocks
      PlatformMockHelper.teardownMocks();
    });

    setUp(() async {
      // Clear test caches before each test
      TestHelper.clearTestCaches();
    });

    test('should store and retrieve Interview entity correctly', () async {
      // Arrange
      final box = await Hive.openBox<InterviewModel>('test_interviews');

      final interview = Interview(
        id: 'test-interview-1',
        candidateName: 'John Doe',
        role: Role.flutter,
        level: Level.associate,
        startTime: DateTime.now(),
        responses: [],
        status: InterviewStatus.notStarted,
      );

      final interviewModel = InterviewModel.fromEntity(interview);

      // Act
      await box.put(interview.id, interviewModel);
      final retrieved = box.get(interview.id);

      // Assert
      expect(retrieved, isNotNull);
      final retrievedInterview = retrieved!.toEntity();
      expect(retrievedInterview.id, equals(interview.id));
      expect(retrievedInterview.candidateName, equals(interview.candidateName));
      expect(retrievedInterview.role, equals(interview.role));
      expect(retrievedInterview.level, equals(interview.level));

      // Cleanup
      await box.close();
    });

    test('should handle enum serialization correctly', () async {
      // Arrange
      final box = await Hive.openBox<Role>('test_roles');

      // Act
      await box.put('role1', Role.flutter);
      await box.put('role2', Role.backend);
      await box.put('role3', Role.fullStack);

      final retrievedRole1 = box.get('role1');
      final retrievedRole2 = box.get('role2');
      final retrievedRole3 = box.get('role3');

      // Assert
      expect(retrievedRole1, equals(Role.flutter));
      expect(retrievedRole2, equals(Role.backend));
      expect(retrievedRole3, equals(Role.fullStack));

      // Cleanup
      await box.close();
    });

    test('should handle complex entity with nested objects', () async {
      // Arrange
      final box = await Hive.openBox<InterviewModel>('test_complex_interviews');

      final interview = Interview(
        id: 'complex-interview-1',
        candidateName: 'Jane Smith',
        role: Role.fullStack,
        level: Level.senior,
        startTime: DateTime(2024, 1, 1, 10, 0),
        endTime: DateTime(2024, 1, 1, 11, 30),
        responses: [
          QuestionResponse(
            questionId: 'q1',
            isCorrect: true,
            notes: 'Excellent answer',
            timestamp: DateTime(2024, 1, 1, 10, 15),
          ),
          QuestionResponse(
            questionId: 'q2',
            isCorrect: false,
            notes: 'Needs improvement',
            timestamp: DateTime(2024, 1, 1, 10, 30),
          ),
        ],
        status: InterviewStatus.completed,
        overallScore: 85.5,
      );

      final interviewModel = InterviewModel.fromEntity(interview);

      // Act
      await box.put(interview.id, interviewModel);
      final retrieved = box.get(interview.id);

      // Assert
      expect(retrieved, isNotNull);
      final retrievedInterview = retrieved!.toEntity();
      expect(retrievedInterview.responses.length, equals(2));
      expect(retrievedInterview.responses[0].isCorrect, isTrue);
      expect(retrievedInterview.responses[1].isCorrect, isFalse);
      expect(retrievedInterview.overallScore, equals(85.5));
      expect(retrievedInterview.status, equals(InterviewStatus.completed));

      // Cleanup
      await box.close();
    });
  });
}
