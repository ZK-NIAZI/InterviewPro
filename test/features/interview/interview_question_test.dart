import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:interview_pro_app/shared/domain/entities/interview_question.dart';
import 'package:interview_pro_app/shared/domain/entities/question_category.dart';
import 'package:interview_pro_app/shared/domain/repositories/interview_question_repository.dart';
import 'package:interview_pro_app/features/interview/presentation/providers/interview_question_provider.dart';

import '../../helpers/test_helper.dart';
import 'interview_question_test.mocks.dart';

@GenerateMocks([InterviewQuestionRepository])
void main() {
  group('InterviewQuestion Entity Tests', () {
    test('should create InterviewQuestion with all properties', () {
      final question = InterviewQuestion(
        id: 'test_001',
        question: 'What is Flutter?',
        category: 'technical',
        difficulty: 'beginner',
        expectedDuration: 5,
        tags: ['flutter', 'mobile'],
        sampleAnswer: 'Flutter is a UI toolkit',
        evaluationCriteria: ['Clear explanation', 'Technical accuracy'],
        roleSpecific: 'Flutter Developer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(question.id, 'test_001');
      expect(question.question, 'What is Flutter?');
      expect(question.category, 'technical');
      expect(question.difficulty, 'beginner');
      expect(question.expectedDuration, 5);
      expect(question.tags, ['flutter', 'mobile']);
      expect(question.isActive, true);
    });

    test('should match difficulty correctly', () {
      final question = InterviewQuestion(
        id: 'test_001',
        question: 'Test question',
        category: 'technical',
        difficulty: 'intermediate',
        expectedDuration: 5,
        tags: [],
        evaluationCriteria: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(question.matchesDifficulty('intermediate'), true);
      expect(question.matchesDifficulty('Intermediate'), true);
      expect(question.matchesDifficulty('beginner'), false);
    });

    test('should check role suitability correctly', () {
      final question = InterviewQuestion(
        id: 'test_001',
        question: 'Test question',
        category: 'technical',
        difficulty: 'intermediate',
        expectedDuration: 5,
        tags: [],
        evaluationCriteria: [],
        roleSpecific: 'Flutter Developer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(question.isSuitableForRole('Flutter Developer'), true);
      expect(question.isSuitableForRole('flutter'), true);
      expect(question.isSuitableForRole('Product Manager'), false);
      expect(question.isSuitableForRole(null), true);
    });

    test('should match search criteria correctly', () {
      final question = InterviewQuestion(
        id: 'test_001',
        question: 'Test question',
        category: 'technical',
        difficulty: 'intermediate',
        expectedDuration: 5,
        tags: ['flutter', 'mobile'],
        evaluationCriteria: [],
        roleSpecific: 'Flutter Developer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(
        question.matchesSearchCriteria(
          categoryFilter: 'technical',
          difficultyFilter: 'intermediate',
          roleFilter: 'Flutter Developer',
          tagFilters: ['flutter'],
        ),
        true,
      );

      expect(
        question.matchesSearchCriteria(categoryFilter: 'behavioral'),
        false,
      );
    });

    test('should convert to and from JSON correctly', () {
      final originalQuestion = InterviewQuestion(
        id: 'test_001',
        question: 'What is Flutter?',
        category: 'technical',
        difficulty: 'beginner',
        expectedDuration: 5,
        tags: ['flutter', 'mobile'],
        sampleAnswer: 'Flutter is a UI toolkit',
        evaluationCriteria: ['Clear explanation'],
        roleSpecific: 'Flutter Developer',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      final json = originalQuestion
          .toTestJson(); // Use toTestJson for complete serialization
      final reconstructedQuestion = InterviewQuestion.fromJson(json);

      expect(reconstructedQuestion.id, originalQuestion.id);
      expect(reconstructedQuestion.question, originalQuestion.question);
      expect(reconstructedQuestion.category, originalQuestion.category);
      expect(reconstructedQuestion.difficulty, originalQuestion.difficulty);
      expect(reconstructedQuestion.tags, originalQuestion.tags);
      expect(reconstructedQuestion.roleSpecific, originalQuestion.roleSpecific);
    });
  });

  group('QuestionCategoryEntity Entity Tests', () {
    test('should create QuestionCategoryEntity with all properties', () {
      final category = QuestionCategoryEntity(
        id: 'technical',
        name: 'Technical Skills',
        description: 'Questions to assess technical competency',
        questionCount: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(category.id, 'technical');
      expect(category.name, 'Technical Skills');
      expect(category.description, 'Questions to assess technical competency');
      expect(category.questionCount, 10);
      expect(category.isActive, true);
    });

    test('should convert to and from JSON correctly', () {
      final originalCategory = QuestionCategoryEntity(
        id: 'technical',
        name: 'Technical Skills',
        description: 'Questions to assess technical competency',
        questionCount: 10,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      final json = originalCategory
          .toTestJson(); // Use toTestJson for complete serialization
      final reconstructedCategory = QuestionCategoryEntity.fromJson(json);

      expect(reconstructedCategory.id, originalCategory.id);
      expect(reconstructedCategory.name, originalCategory.name);
      expect(reconstructedCategory.description, originalCategory.description);
      expect(
        reconstructedCategory.questionCount,
        originalCategory.questionCount,
      );
    });
  });

  group('InterviewQuestionProvider Tests', () {
    late MockInterviewQuestionRepository mockRepository;
    late InterviewQuestionProvider provider;

    setUp(() async {
      // Setup clean test environment
      await TestHelper.setupTest();

      // Create fresh mocks and provider for each test
      mockRepository = MockInterviewQuestionRepository();
      provider = InterviewQuestionProvider(mockRepository);
    });

    tearDown(() async {
      // Cleanup after each test
      await TestHelper.teardownTest();
    });

    test('should load questions successfully', () async {
      final mockQuestions = [
        InterviewQuestion(
          id: 'test_001',
          question: 'What is Flutter?',
          category: 'technical',
          difficulty: 'beginner',
          expectedDuration: 5,
          tags: ['flutter'],
          evaluationCriteria: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.hasQuestions()).thenAnswer((_) async => true);
      when(
        mockRepository.getQuestions(),
      ).thenAnswer((_) async => mockQuestions);

      await provider.loadQuestions();

      expect(provider.questions, mockQuestions);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('should handle loading errors gracefully', () async {
      // Ensure completely clean state
      TestHelper.clearTestCaches();
      provider.setItems([]); // Clear provider items
      provider.clearError(); // Clear any existing errors
      provider.resetBackendTried(); // Reset backend tried flag

      // Mock repository to throw error
      when(mockRepository.hasQuestions()).thenThrow(Exception('Network error'));

      // Attempt to load questions
      await provider.loadQuestions();

      // Verify error handling
      expect(provider.questions, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, isNotNull);
    });

    test('should filter questions correctly', () {
      final questions = [
        InterviewQuestion(
          id: 'test_001',
          question: 'Technical question',
          category: 'technical',
          difficulty: 'beginner',
          expectedDuration: 5,
          tags: ['flutter'],
          evaluationCriteria: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        InterviewQuestion(
          id: 'test_002',
          question: 'Behavioral question',
          category: 'behavioral',
          difficulty: 'intermediate',
          expectedDuration: 5,
          tags: ['communication'],
          evaluationCriteria: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      provider.setItems(questions);
      provider.setSelectedCategory('technical');

      final filteredQuestions = provider.filteredQuestions;

      expect(filteredQuestions.length, 1);
      expect(filteredQuestions.first.category, 'technical');
    });

    test('should clear filters correctly', () {
      provider.setSelectedCategory('technical');
      provider.setSelectedDifficulty('beginner');
      provider.setSelectedRole('Flutter Developer');
      provider.setSelectedTags(['flutter']);

      provider.clearFilters();

      expect(provider.selectedCategory, null);
      expect(provider.selectedDifficulty, null);
      expect(provider.selectedRole, null);
      expect(provider.selectedTags, isEmpty);
    });
  });
}
