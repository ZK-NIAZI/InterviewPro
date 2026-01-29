import 'package:flutter_test/flutter_test.dart';
import 'package:interview_pro_app/shared/data/services/default_question_bank_service.dart';
import 'package:interview_pro_app/shared/domain/entities/entities.dart';
import 'package:interview_pro_app/shared/domain/repositories/question_repository.dart';

// Simple fake repository for testing
class FakeQuestionRepository implements QuestionRepository {
  final List<Question> _questions = [];

  @override
  Future<List<Question>> getAllQuestions() async => List.from(_questions);

  @override
  Future<Question?> getQuestionById(String id) async {
    try {
      return _questions.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveQuestion(Question question) async {
    _questions.add(question);
  }

  @override
  Future<void> updateQuestion(Question question) async {
    final index = _questions.indexWhere((q) => q.id == question.id);
    if (index != -1) {
      _questions[index] = question;
    }
  }

  @override
  Future<void> deleteQuestion(String id) async {
    _questions.removeWhere((q) => q.id == id);
  }

  @override
  Future<List<Question>> getQuestionsByCategory(
    QuestionCategory category,
  ) async {
    return _questions.where((q) => q.category == category).toList();
  }

  @override
  Future<List<Question>> getQuestionsByRole(Role role) async {
    return _questions.where((q) => q.applicableRoles.contains(role)).toList();
  }

  @override
  Future<List<Question>> getQuestionsByLevel(Level level) async {
    return _questions.where((q) => q.difficulty == level).toList();
  }

  @override
  Future<List<Question>> getQuestionsByRoleAndLevel(
    Role role,
    Level level,
  ) async {
    return _questions
        .where((q) => q.applicableRoles.contains(role) && q.difficulty == level)
        .toList();
  }

  @override
  Future<List<Question>> getQuestionsByCategoryAndRole(
    QuestionCategory category,
    Role role,
  ) async {
    return _questions
        .where(
          (q) => q.category == category && q.applicableRoles.contains(role),
        )
        .toList();
  }

  @override
  Future<List<Question>> getQuestionsByCategoryRoleAndLevel(
    QuestionCategory category,
    Role role,
    Level level,
  ) async {
    return _questions
        .where(
          (q) =>
              q.category == category &&
              q.applicableRoles.contains(role) &&
              q.difficulty == level,
        )
        .toList();
  }

  @override
  Future<List<Question>> searchQuestions(String searchText) async {
    return _questions
        .where((q) => q.text.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  @override
  Future<List<Question>> getQuestionsByTags(List<String> tags) async {
    return _questions
        .where((q) => q.tags.any((tag) => tags.contains(tag)))
        .toList();
  }

  @override
  Future<List<Question>> getRandomQuestions(
    Role role,
    Level level, {
    int count = 10,
  }) async {
    final filtered = await getQuestionsByRoleAndLevel(role, level);
    filtered.shuffle();
    return filtered.take(count).toList();
  }

  @override
  Future<int> getQuestionCount() async => _questions.length;

  @override
  Future<int> getQuestionCountByCategory(QuestionCategory category) async {
    return _questions.where((q) => q.category == category).length;
  }

  @override
  Future<int> getQuestionCountByRole(Role role) async {
    return _questions.where((q) => q.applicableRoles.contains(role)).length;
  }

  @override
  Future<int> getQuestionCountByLevel(Level level) async {
    return _questions.where((q) => q.difficulty == level).length;
  }

  @override
  Future<bool> questionExists(String id) async {
    return _questions.any((q) => q.id == id);
  }

  @override
  Future<void> saveQuestions(List<Question> questions) async {
    _questions.addAll(questions);
  }
}

void main() {
  group('DefaultQuestionBankService Simple Tests', () {
    late DefaultQuestionBankService service;
    late FakeQuestionRepository repository;

    setUp(() {
      repository = FakeQuestionRepository();
      service = DefaultQuestionBankService(repository);
    });

    test(
      'should initialize default questions when repository is empty',
      () async {
        // Arrange
        expect(await repository.getQuestionCount(), equals(0));

        // Act
        await service.initializeDefaultQuestions();

        // Assert
        final count = await repository.getQuestionCount();
        expect(count, greaterThan(0));
      },
    );

    test('should create questions for all categories', () async {
      // Act
      await service.initializeDefaultQuestions();

      // Assert
      for (final category in QuestionCategory.values) {
        final categoryQuestions = await repository.getQuestionsByCategory(
          category,
        );
        expect(
          categoryQuestions.isNotEmpty,
          true,
          reason: 'No questions found for category: ${category.displayName}',
        );
      }
    });

    test('should create questions for all roles', () async {
      // Act
      await service.initializeDefaultQuestions();

      // Assert
      for (final role in Role.values) {
        final roleQuestions = await repository.getQuestionsByRole(role);
        expect(
          roleQuestions.isNotEmpty,
          true,
          reason: 'No questions found for role: ${role.displayName}',
        );
      }
    });

    test('should create questions for all difficulty levels', () async {
      // Act
      await service.initializeDefaultQuestions();

      // Assert
      for (final level in Level.values) {
        final levelQuestions = await repository.getQuestionsByLevel(level);
        expect(
          levelQuestions.isNotEmpty,
          true,
          reason: 'No questions found for level: ${level.displayName}',
        );
      }
    });

    test('should not duplicate questions on subsequent calls', () async {
      // Act
      await service.initializeDefaultQuestions();
      final firstCount = await repository.getQuestionCount();

      await service.initializeDefaultQuestions();
      final secondCount = await repository.getQuestionCount();

      // Assert
      expect(secondCount, equals(firstCount));
    });

    test('should create questions with proper structure', () async {
      // Act
      await service.initializeDefaultQuestions();

      // Assert
      final allQuestions = await repository.getAllQuestions();
      expect(allQuestions.isNotEmpty, true);

      for (final question in allQuestions) {
        expect(question.id.isNotEmpty, true);
        expect(question.text.isNotEmpty, true);
        expect(question.applicableRoles.isNotEmpty, true);
        expect(question.tags.isNotEmpty, true);
        expect(question.text.trim().length, greaterThan(10));
      }
    });

    test('should create questions with unique IDs', () async {
      // Act
      await service.initializeDefaultQuestions();

      // Assert
      final allQuestions = await repository.getAllQuestions();
      final ids = allQuestions.map((q) => q.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, equals(uniqueIds.length));
    });
  });
}
