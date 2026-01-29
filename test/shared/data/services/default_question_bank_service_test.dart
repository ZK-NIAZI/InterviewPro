import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:interview_pro_app/shared/data/services/default_question_bank_service.dart';
import 'package:interview_pro_app/shared/domain/entities/entities.dart';
import 'package:interview_pro_app/shared/domain/repositories/question_repository.dart';

import 'default_question_bank_service_test.mocks.dart';

@GenerateMocks([QuestionRepository])
void main() {
  group('DefaultQuestionBankService', () {
    late DefaultQuestionBankService service;
    late MockQuestionRepository mockRepository;

    setUp(() {
      mockRepository = MockQuestionRepository();
      service = DefaultQuestionBankService(mockRepository);
    });

    group('initializeDefaultQuestions', () {
      test('should initialize questions when repository is empty', () async {
        // Arrange
        when(mockRepository.getQuestionCount()).thenAnswer((_) async => 0);
        when(mockRepository.saveQuestions(any)).thenAnswer((_) async {});

        // Act
        await service.initializeDefaultQuestions();

        // Assert
        verify(mockRepository.getQuestionCount()).called(1);
        verify(mockRepository.saveQuestions(any)).called(1);
      });

      test(
        'should not initialize questions when repository has existing questions',
        () async {
          // Arrange
          when(mockRepository.getQuestionCount()).thenAnswer((_) async => 10);

          // Act
          await service.initializeDefaultQuestions();

          // Assert
          verify(mockRepository.getQuestionCount()).called(1);
          verifyNever(mockRepository.saveQuestions(any));
        },
      );

      test('should create questions for all categories', () async {
        // Arrange
        when(mockRepository.getQuestionCount()).thenAnswer((_) async => 0);
        List<Question>? capturedQuestions;
        when(mockRepository.saveQuestions(any)).thenAnswer((invocation) async {
          capturedQuestions =
              invocation.positionalArguments[0] as List<Question>;
        });

        // Act
        await service.initializeDefaultQuestions();

        // Assert
        expect(capturedQuestions, isNotNull);
        expect(capturedQuestions!.isNotEmpty, true);

        // Verify all categories are represented
        final categories = capturedQuestions!.map((q) => q.category).toSet();
        expect(categories, containsAll(QuestionCategory.values));
      });

      test('should create questions for all roles', () async {
        // Arrange
        when(mockRepository.getQuestionCount()).thenAnswer((_) async => 0);
        List<Question>? capturedQuestions;
        when(mockRepository.saveQuestions(any)).thenAnswer((invocation) async {
          capturedQuestions =
              invocation.positionalArguments[0] as List<Question>;
        });

        // Act
        await service.initializeDefaultQuestions();

        // Assert
        expect(capturedQuestions, isNotNull);
        expect(capturedQuestions!.isNotEmpty, true);

        // Verify all roles are represented in applicable roles
        final allApplicableRoles = capturedQuestions!
            .expand((q) => q.applicableRoles)
            .toSet();
        expect(allApplicableRoles, containsAll(Role.values));
      });

      test('should create questions for all difficulty levels', () async {
        // Arrange
        when(mockRepository.getQuestionCount()).thenAnswer((_) async => 0);
        List<Question>? capturedQuestions;
        when(mockRepository.saveQuestions(any)).thenAnswer((invocation) async {
          capturedQuestions =
              invocation.positionalArguments[0] as List<Question>;
        });

        // Act
        await service.initializeDefaultQuestions();

        // Assert
        expect(capturedQuestions, isNotNull);
        expect(capturedQuestions!.isNotEmpty, true);

        // Verify all difficulty levels are represented
        final difficulties = capturedQuestions!
            .map((q) => q.difficulty)
            .toSet();
        expect(difficulties, containsAll(Level.values));
      });

      test('should create questions with unique IDs', () async {
        // Arrange
        when(mockRepository.getQuestionCount()).thenAnswer((_) async => 0);
        List<Question>? capturedQuestions;
        when(mockRepository.saveQuestions(any)).thenAnswer((invocation) async {
          capturedQuestions =
              invocation.positionalArguments[0] as List<Question>;
        });

        // Act
        await service.initializeDefaultQuestions();

        // Assert
        expect(capturedQuestions, isNotNull);
        expect(capturedQuestions!.isNotEmpty, true);

        // Verify all IDs are unique
        final ids = capturedQuestions!.map((q) => q.id).toList();
        final uniqueIds = ids.toSet();
        expect(ids.length, equals(uniqueIds.length));
      });

      test('should create questions with proper structure', () async {
        // Arrange
        when(mockRepository.getQuestionCount()).thenAnswer((_) async => 0);
        List<Question>? capturedQuestions;
        when(mockRepository.saveQuestions(any)).thenAnswer((invocation) async {
          capturedQuestions =
              invocation.positionalArguments[0] as List<Question>;
        });

        // Act
        await service.initializeDefaultQuestions();

        // Assert
        expect(capturedQuestions, isNotNull);
        expect(capturedQuestions!.isNotEmpty, true);

        // Verify each question has required fields
        for (final question in capturedQuestions!) {
          expect(question.id.isNotEmpty, true);
          expect(question.text.isNotEmpty, true);
          expect(question.applicableRoles.isNotEmpty, true);
          expect(question.tags.isNotEmpty, true);
        }
      });

      test(
        'should create programming fundamentals questions for all levels',
        () async {
          // Arrange
          when(mockRepository.getQuestionCount()).thenAnswer((_) async => 0);
          List<Question>? capturedQuestions;
          when(mockRepository.saveQuestions(any)).thenAnswer((
            invocation,
          ) async {
            capturedQuestions =
                invocation.positionalArguments[0] as List<Question>;
          });

          // Act
          await service.initializeDefaultQuestions();

          // Assert
          final pfQuestions = capturedQuestions!
              .where(
                (q) => q.category == QuestionCategory.programmingFundamentals,
              )
              .toList();

          expect(pfQuestions.isNotEmpty, true);

          // Verify all levels are represented in programming fundamentals
          final pfLevels = pfQuestions.map((q) => q.difficulty).toSet();
          expect(pfLevels, containsAll(Level.values));
        },
      );

      test('should create role-specific questions for each role', () async {
        // Arrange
        when(mockRepository.getQuestionCount()).thenAnswer((_) async => 0);
        List<Question>? capturedQuestions;
        when(mockRepository.saveQuestions(any)).thenAnswer((invocation) async {
          capturedQuestions =
              invocation.positionalArguments[0] as List<Question>;
        });

        // Act
        await service.initializeDefaultQuestions();

        // Assert
        final roleSpecificQuestions = capturedQuestions!
            .where((q) => q.category == QuestionCategory.roleSpecificTechnical)
            .toList();

        expect(roleSpecificQuestions.isNotEmpty, true);

        // Verify each role has specific questions
        for (final role in Role.values) {
          final roleQuestions = roleSpecificQuestions
              .where((q) => q.applicableRoles.contains(role))
              .toList();
          expect(
            roleQuestions.isNotEmpty,
            true,
            reason: 'No questions found for role: ${role.displayName}',
          );
        }
      });

      test('should create modern development practices questions', () async {
        // Arrange
        when(mockRepository.getQuestionCount()).thenAnswer((_) async => 0);
        List<Question>? capturedQuestions;
        when(mockRepository.saveQuestions(any)).thenAnswer((invocation) async {
          capturedQuestions =
              invocation.positionalArguments[0] as List<Question>;
        });

        // Act
        await service.initializeDefaultQuestions();

        // Assert
        final mdpQuestions = capturedQuestions!
            .where(
              (q) => q.category == QuestionCategory.modernDevelopmentPractices,
            )
            .toList();

        expect(mdpQuestions.isNotEmpty, true);

        // Verify all levels are represented
        final mdpLevels = mdpQuestions.map((q) => q.difficulty).toSet();
        expect(mdpLevels, containsAll(Level.values));
      });

      test('should create soft skills questions', () async {
        // Arrange
        when(mockRepository.getQuestionCount()).thenAnswer((_) async => 0);
        List<Question>? capturedQuestions;
        when(mockRepository.saveQuestions(any)).thenAnswer((invocation) async {
          capturedQuestions =
              invocation.positionalArguments[0] as List<Question>;
        });

        // Act
        await service.initializeDefaultQuestions();

        // Assert
        final softSkillsQuestions = capturedQuestions!
            .where((q) => q.category == QuestionCategory.softSkills)
            .toList();

        expect(softSkillsQuestions.isNotEmpty, true);

        // Verify all levels are represented
        final ssLevels = softSkillsQuestions.map((q) => q.difficulty).toSet();
        expect(ssLevels, containsAll(Level.values));
      });

      test('should handle repository errors gracefully', () async {
        // Arrange
        when(
          mockRepository.getQuestionCount(),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(() => service.initializeDefaultQuestions(), throwsException);
      });
    });
  });
}
