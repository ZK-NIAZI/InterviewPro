import 'package:flutter_test/flutter_test.dart';
import 'package:interview_pro_app/core/services/service_locator.dart';
import 'package:interview_pro_app/shared/data/services/default_question_bank_service.dart';
import 'package:interview_pro_app/shared/data/services/hive_service.dart';
import 'package:interview_pro_app/shared/domain/entities/entities.dart';
import 'package:interview_pro_app/shared/domain/repositories/question_repository.dart';

void main() {
  group('Default Question Bank Integration Tests', () {
    setUpAll(() async {
      // Initialize Hive for testing
      await HiveService.init();

      // Initialize dependencies
      await initializeDependencies();
    });

    tearDownAll(() async {
      // Clean up
      await HiveService.clearAllData();
    });

    test('should initialize default questions on first app launch', () async {
      // Arrange
      final questionRepository = sl<QuestionRepository>();
      final defaultQuestionBankService = sl<DefaultQuestionBankService>();

      // Ensure we start with an empty repository
      await HiveService.clearAllData();
      await initializeDependencies(); // Re-initialize after clearing

      // Act
      await defaultQuestionBankService.initializeDefaultQuestions();

      // Assert
      final finalCount = await questionRepository.getQuestionCount();
      expect(finalCount, greaterThan(0));

      // Verify all categories are represented
      final allQuestions = await questionRepository.getAllQuestions();
      final categories = allQuestions.map((q) => q.category).toSet();
      expect(categories, containsAll(QuestionCategory.values));

      // Verify all roles are represented
      final allApplicableRoles = allQuestions
          .expand((q) => q.applicableRoles)
          .toSet();
      expect(allApplicableRoles, containsAll(Role.values));

      // Verify all difficulty levels are represented
      final difficulties = allQuestions.map((q) => q.difficulty).toSet();
      expect(difficulties, containsAll(Level.values));
    });

    test(
      'should not duplicate questions on subsequent initializations',
      () async {
        // Arrange
        final questionRepository = sl<QuestionRepository>();
        final defaultQuestionBankService = sl<DefaultQuestionBankService>();

        // Get initial count (should have questions from previous test)
        final initialCount = await questionRepository.getQuestionCount();
        expect(initialCount, greaterThan(0));

        // Act - try to initialize again
        await defaultQuestionBankService.initializeDefaultQuestions();

        // Assert - count should remain the same
        final finalCount = await questionRepository.getQuestionCount();
        expect(finalCount, equals(initialCount));
      },
    );

    test('should create questions with proper structure and content', () async {
      // Arrange
      final questionRepository = sl<QuestionRepository>();

      // Act
      final allQuestions = await questionRepository.getAllQuestions();

      // Assert
      expect(allQuestions.isNotEmpty, true);

      for (final question in allQuestions) {
        // Verify required fields
        expect(question.id.isNotEmpty, true);
        expect(question.text.isNotEmpty, true);
        expect(question.applicableRoles.isNotEmpty, true);
        expect(question.tags.isNotEmpty, true);

        // Verify ID format follows expected pattern
        expect(question.id, matches(r'^[a-z_]+_[a-z]+_\d+$'));

        // Verify question text is meaningful (not just whitespace)
        expect(question.text.trim().length, greaterThan(10));

        // Verify tags are meaningful
        for (final tag in question.tags) {
          expect(tag.isNotEmpty, true);
          expect(tag.trim(), equals(tag));
        }
      }
    });

    test('should create appropriate questions for each role', () async {
      // Arrange
      final questionRepository = sl<QuestionRepository>();

      // Act & Assert for each role
      for (final role in Role.values) {
        final roleQuestions = await questionRepository.getQuestionsByRole(role);
        expect(
          roleQuestions.isNotEmpty,
          true,
          reason: 'No questions found for role: ${role.displayName}',
        );

        // Verify questions are actually applicable to the role
        for (final question in roleQuestions) {
          expect(
            question.applicableRoles.contains(role),
            true,
            reason:
                'Question ${question.id} not applicable to role ${role.displayName}',
          );
        }
      }
    });

    test('should create questions for each difficulty level', () async {
      // Arrange
      final questionRepository = sl<QuestionRepository>();

      // Act & Assert for each level
      for (final level in Level.values) {
        final levelQuestions = await questionRepository.getQuestionsByLevel(
          level,
        );
        expect(
          levelQuestions.isNotEmpty,
          true,
          reason: 'No questions found for level: ${level.displayName}',
        );

        // Verify questions match the difficulty level
        for (final question in levelQuestions) {
          expect(
            question.difficulty,
            equals(level),
            reason: 'Question ${question.id} has wrong difficulty level',
          );
        }
      }
    });

    test('should create questions for each category', () async {
      // Arrange
      final questionRepository = sl<QuestionRepository>();

      // Act & Assert for each category
      for (final category in QuestionCategory.values) {
        final categoryQuestions = await questionRepository
            .getQuestionsByCategory(category);
        expect(
          categoryQuestions.isNotEmpty,
          true,
          reason: 'No questions found for category: ${category.displayName}',
        );

        // Verify questions belong to the correct category
        for (final question in categoryQuestions) {
          expect(
            question.category,
            equals(category),
            reason: 'Question ${question.id} has wrong category',
          );
        }
      }
    });

    test(
      'should create role-specific technical questions for each role',
      () async {
        // Arrange
        final questionRepository = sl<QuestionRepository>();

        // Act
        final roleSpecificQuestions = await questionRepository
            .getQuestionsByCategory(QuestionCategory.roleSpecificTechnical);

        // Assert
        expect(roleSpecificQuestions.isNotEmpty, true);

        // Verify each role has specific technical questions
        for (final role in Role.values) {
          final roleQuestions = roleSpecificQuestions
              .where((q) => q.applicableRoles.contains(role))
              .toList();
          expect(
            roleQuestions.isNotEmpty,
            true,
            reason:
                'No role-specific technical questions for ${role.displayName}',
          );
        }
      },
    );

    test(
      'should create programming fundamentals questions applicable to all roles',
      () async {
        // Arrange
        final questionRepository = sl<QuestionRepository>();

        // Act
        final pfQuestions = await questionRepository.getQuestionsByCategory(
          QuestionCategory.programmingFundamentals,
        );

        // Assert
        expect(pfQuestions.isNotEmpty, true);

        // Most programming fundamentals questions should be applicable to all roles
        final universalQuestions = pfQuestions
            .where((q) => q.applicableRoles.length == Role.values.length)
            .toList();
        expect(universalQuestions.isNotEmpty, true);
      },
    );

    test('should create soft skills questions applicable to all roles', () async {
      // Arrange
      final questionRepository = sl<QuestionRepository>();

      // Act
      final softSkillsQuestions = await questionRepository
          .getQuestionsByCategory(QuestionCategory.softSkills);

      // Assert
      expect(softSkillsQuestions.isNotEmpty, true);

      // All soft skills questions should be applicable to all roles
      for (final question in softSkillsQuestions) {
        expect(
          question.applicableRoles,
          containsAll(Role.values),
          reason:
              'Soft skills question ${question.id} should be applicable to all roles',
        );
      }
    });
  });
}
