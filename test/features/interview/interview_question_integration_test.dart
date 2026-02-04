import 'package:flutter_test/flutter_test.dart';
import 'package:interview_pro_app/shared/domain/entities/interview_question.dart';

void main() {
  group('Interview Question Entity Tests', () {
    group('Question Entity Functionality', () {
      test('should create interview question with all properties', () {
        // Arrange & Act
        final question = InterviewQuestion(
          id: 'test_001',
          question: 'What is Flutter?',
          category: 'technical',
          difficulty: 'beginner',
          expectedDuration: 5,
          tags: ['flutter', 'mobile'],
          evaluationCriteria: ['Basic knowledge'],
          roleSpecific: 'Flutter Developer',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(question.id, equals('test_001'));
        expect(question.question, equals('What is Flutter?'));
        expect(question.category, equals('technical'));
        expect(question.difficulty, equals('beginner'));
        expect(question.roleSpecific, equals('Flutter Developer'));
      });

      test('should match difficulty correctly', () {
        // Arrange
        final question = InterviewQuestion(
          id: 'test_001',
          question: 'Test question',
          category: 'technical',
          difficulty: 'intermediate',
          expectedDuration: 5,
          tags: ['test'],
          evaluationCriteria: ['Knowledge'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(question.matchesDifficulty('intermediate'), isTrue);
        expect(question.matchesDifficulty('beginner'), isFalse);
        expect(
          question.matchesDifficulty('INTERMEDIATE'),
          isTrue,
        ); // Case insensitive
      });

      test('should check role suitability correctly', () {
        // Arrange
        final question = InterviewQuestion(
          id: 'test_001',
          question: 'Test question',
          category: 'role-specific',
          difficulty: 'intermediate',
          expectedDuration: 5,
          tags: ['flutter'],
          evaluationCriteria: ['Knowledge'],
          roleSpecific: 'Flutter Developer',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(question.isSuitableForRole('Flutter Developer'), isTrue);
        expect(question.isSuitableForRole('Flutter'), isTrue);
        expect(question.isSuitableForRole('React Developer'), isFalse);
        expect(
          question.isSuitableForRole(null),
          isTrue,
        ); // Null role should match
      });

      test('should match search criteria correctly', () {
        // Arrange
        final question = InterviewQuestion(
          id: 'test_001',
          question: 'Test question',
          category: 'technical',
          difficulty: 'intermediate',
          expectedDuration: 5,
          tags: ['flutter', 'mobile', 'dart'],
          evaluationCriteria: ['Knowledge'],
          roleSpecific: 'Flutter Developer',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          question.matchesSearchCriteria(
            categoryFilter: 'technical',
            difficultyFilter: 'intermediate',
            roleFilter: 'Flutter Developer',
            tagFilters: ['flutter'],
          ),
          isTrue,
        );

        expect(
          question.matchesSearchCriteria(categoryFilter: 'behavioral'),
          isFalse,
        );
      });

      test('should convert to and from JSON correctly', () {
        // Arrange
        final originalQuestion = InterviewQuestion(
          id: 'test_001',
          question: 'What is Flutter?',
          category: 'technical',
          difficulty: 'beginner',
          expectedDuration: 5,
          tags: ['flutter', 'mobile'],
          sampleAnswer: 'Flutter is a UI toolkit',
          evaluationCriteria: ['Basic knowledge', 'Clear explanation'],
          roleSpecific: 'Flutter Developer',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
          isActive: true,
        );

        // Act
        final json = originalQuestion
            .toTestJson(); // Use toTestJson for complete serialization
        final reconstructedQuestion = InterviewQuestion.fromJson(json);

        // Assert
        expect(reconstructedQuestion.id, equals(originalQuestion.id));
        expect(
          reconstructedQuestion.question,
          equals(originalQuestion.question),
        );
        expect(
          reconstructedQuestion.category,
          equals(originalQuestion.category),
        );
        expect(
          reconstructedQuestion.difficulty,
          equals(originalQuestion.difficulty),
        );
        expect(reconstructedQuestion.tags, equals(originalQuestion.tags));
        expect(
          reconstructedQuestion.sampleAnswer,
          equals(originalQuestion.sampleAnswer),
        );
        expect(
          reconstructedQuestion.evaluationCriteria,
          equals(originalQuestion.evaluationCriteria),
        );
        expect(
          reconstructedQuestion.roleSpecific,
          equals(originalQuestion.roleSpecific),
        );
        expect(
          reconstructedQuestion.isActive,
          equals(originalQuestion.isActive),
        );
      });
    });

    group('Display Properties', () {
      test('should return correct category display names', () {
        // Test cases for different categories
        final testCases = [
          {'category': 'technical', 'expected': 'Technical Skills'},
          {'category': 'behavioral', 'expected': 'Behavioral & Soft Skills'},
          {'category': 'leadership', 'expected': 'Leadership & Management'},
          {'category': 'role-specific', 'expected': 'Role-Specific Questions'},
          {'category': 'custom', 'expected': 'custom'},
        ];

        for (final testCase in testCases) {
          final question = InterviewQuestion(
            id: 'test',
            question: 'Test',
            category: testCase['category']!,
            difficulty: 'intermediate',
            expectedDuration: 5,
            tags: [],
            evaluationCriteria: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(question.categoryDisplayName, equals(testCase['expected']));
        }
      });

      test('should return correct difficulty display names', () {
        // Test cases for different difficulties
        final testCases = [
          {'difficulty': 'beginner', 'expected': 'Beginner'},
          {'difficulty': 'intermediate', 'expected': 'Intermediate'},
          {'difficulty': 'advanced', 'expected': 'Advanced'},
          {'difficulty': 'expert', 'expected': 'expert'},
        ];

        for (final testCase in testCases) {
          final question = InterviewQuestion(
            id: 'test',
            question: 'Test',
            category: 'technical',
            difficulty: testCase['difficulty']!,
            expectedDuration: 5,
            tags: [],
            evaluationCriteria: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(question.difficultyDisplayName, equals(testCase['expected']));
        }
      });

      test('should return correct difficulty colors', () {
        // Test cases for difficulty colors
        final testCases = [
          {'difficulty': 'beginner', 'expected': '#4CAF50'},
          {'difficulty': 'intermediate', 'expected': '#FF9800'},
          {'difficulty': 'advanced', 'expected': '#F44336'},
          {'difficulty': 'expert', 'expected': '#757575'},
        ];

        for (final testCase in testCases) {
          final question = InterviewQuestion(
            id: 'test',
            question: 'Test',
            category: 'technical',
            difficulty: testCase['difficulty']!,
            expectedDuration: 5,
            tags: [],
            evaluationCriteria: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(question.difficultyColor, equals(testCase['expected']));
        }
      });
    });
  });
}
