import 'package:flutter_test/flutter_test.dart';
import 'package:interview_pro_app/shared/domain/entities/interview_question.dart';
import 'package:interview_pro_app/shared/data/repositories/interview_question_repository_impl.dart';
import 'package:interview_pro_app/features/interview/presentation/providers/interview_question_provider.dart';
import 'package:interview_pro_app/core/services/service_locator.dart';

import '../../helpers/test_helper.dart';

void main() {
  group('Interview Question Integration Tests', () {
    late InterviewQuestionProvider provider;

    setUpAll(() async {
      await TestHelper.setupTest();
    });

    tearDownAll(() async {
      await TestHelper.teardownTest();
    });

    setUp(() async {
      // Initialize service locator for each test
      await initializeDependencies();
      provider = InterviewQuestionProvider(sl());
    });

    tearDown(() async {
      // Clean up after each test
      TestHelper.clearTestCaches();
    });

    test('should load questions from local JSON successfully', () async {
      // Load questions from provider
      await provider.loadQuestions();

      // Verify questions were loaded
      expect(provider.questions, isNotEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, null);

      // Verify question structure
      final firstQuestion = provider.questions.first;
      expect(firstQuestion.id, isNotEmpty);
      expect(firstQuestion.question, isNotEmpty);
      expect(firstQuestion.category, isNotEmpty);
      expect(firstQuestion.difficulty, isNotEmpty);
      expect(firstQuestion.evaluationCriteria, isNotEmpty);
    });

    test('should filter questions by category correctly', () async {
      await provider.loadQuestions();

      // Set category filter
      provider.setSelectedCategory('technical');

      final filteredQuestions = provider.filteredQuestions;

      // Verify all filtered questions are technical
      expect(filteredQuestions, isNotEmpty);
      for (final question in filteredQuestions) {
        expect(question.category, 'technical');
      }
    });

    test('should filter questions by difficulty correctly', () async {
      await provider.loadQuestions();

      // Set difficulty filter
      provider.setSelectedDifficulty('beginner');

      final filteredQuestions = provider.filteredQuestions;

      // Verify all filtered questions are beginner level
      expect(filteredQuestions, isNotEmpty);
      for (final question in filteredQuestions) {
        expect(question.difficulty, 'beginner');
      }
    });

    test('should filter questions by role correctly', () async {
      await provider.loadQuestions();

      // Set role filter
      provider.setSelectedRole('Flutter Developer');

      final filteredQuestions = provider.filteredQuestions;

      // Verify filtered questions are suitable for Flutter Developer
      for (final question in filteredQuestions) {
        expect(question.isSuitableForRole('Flutter Developer'), true);
      }
    });

    test('should get random questions correctly', () async {
      final repository = InterviewQuestionRepositoryImpl(sl());

      // Get random questions
      final randomQuestions = await repository.getRandomQuestions(count: 5);

      // Verify we got questions
      expect(randomQuestions, isNotEmpty);
      expect(randomQuestions.length, lessThanOrEqualTo(5));

      // Verify question structure
      for (final question in randomQuestions) {
        expect(question.id, isNotEmpty);
        expect(question.question, isNotEmpty);
        expect(question.category, isNotEmpty);
        expect(question.difficulty, isNotEmpty);
      }
    });

    test('should handle search criteria correctly', () async {
      await provider.loadQuestions();

      // Apply multiple filters
      provider.setSelectedCategory('technical');
      provider.setSelectedDifficulty('intermediate');

      final filteredQuestions = provider.filteredQuestions;

      // Verify all questions match criteria
      for (final question in filteredQuestions) {
        expect(question.category, 'technical');
        expect(question.difficulty, 'intermediate');
      }
    });

    test('should clear filters correctly', () async {
      await provider.loadQuestions();

      // Apply filters
      provider.setSelectedCategory('technical');
      provider.setSelectedDifficulty('beginner');
      provider.setSelectedRole('Flutter Developer');

      // Clear filters
      provider.clearFilters();

      // Verify filters are cleared
      expect(provider.selectedCategory, null);
      expect(provider.selectedDifficulty, null);
      expect(provider.selectedRole, null);
      expect(provider.selectedTags, isEmpty);

      // Verify all questions are shown
      expect(provider.filteredQuestions.length, provider.questions.length);
    });

    test('should handle question creation and JSON serialization', () {
      final question = InterviewQuestion(
        id: 'test_integration_001',
        question: 'Integration test question',
        category: 'technical',
        difficulty: 'intermediate',
        evaluationCriteria: ['Test criteria'],
        roleSpecific: 'Flutter Developer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test JSON serialization
      final json = question.toJson();
      expect(json['question'], 'Integration test question');
      expect(json['category'], 'technical');
      expect(json['difficulty'], 'intermediate');
      expect(json['evaluationCriteria'], ['Test criteria']);
      expect(json['roleSpecific'], 'Flutter Developer');

      // Test JSON deserialization
      final reconstructed = InterviewQuestion.fromJson(json);
      expect(reconstructed.question, question.question);
      expect(reconstructed.category, question.category);
      expect(reconstructed.difficulty, question.difficulty);
      expect(reconstructed.evaluationCriteria, question.evaluationCriteria);
      expect(reconstructed.roleSpecific, question.roleSpecific);
    });

    test('should handle provider state management correctly', () async {
      // Initial state
      expect(provider.isLoading, false);
      expect(provider.questions, isEmpty);
      expect(provider.error, null);

      // Loading state
      final loadingFuture = provider.loadQuestions();
      expect(provider.isLoading, true);

      await loadingFuture;

      // Loaded state
      expect(provider.isLoading, false);
      expect(provider.questions, isNotEmpty);
      expect(provider.error, null);
    });

    test('should handle question statistics correctly', () async {
      final repository = InterviewQuestionRepositoryImpl(sl());

      // Get question statistics
      final stats = await repository.getQuestionStats();

      // Verify statistics structure
      expect(stats['totalQuestions'], isA<int>());
      expect(stats['byCategory'], isA<Map<String, int>>());
      expect(stats['byDifficulty'], isA<Map<String, int>>());

      // Verify we have questions
      expect(stats['totalQuestions'], greaterThan(0));
    });
  });
}
