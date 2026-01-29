import 'package:hive/hive.dart';
import '../../domain/entities/entities.dart';
import '../models/question_model.dart';

/// Local data source for managing question data using Hive
class QuestionLocalDataSource {
  static const String _boxName = 'questions';
  late Box<QuestionModel> _box;

  /// Initialize the data source
  Future<void> init() async {
    _box = await Hive.openBox<QuestionModel>(_boxName);
  }

  /// Get all questions
  Future<List<Question>> getAllQuestions() async {
    final models = _box.values.toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get question by ID
  Future<Question?> getQuestionById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }

  /// Save question
  Future<void> saveQuestion(Question question) async {
    final model = QuestionModel.fromEntity(question);
    await _box.put(question.id, model);
  }

  /// Update question
  Future<void> updateQuestion(Question question) async {
    final model = QuestionModel.fromEntity(question);
    await _box.put(question.id, model);
  }

  /// Delete question
  Future<void> deleteQuestion(String id) async {
    await _box.delete(id);
  }

  /// Get questions by category
  Future<List<Question>> getQuestionsByCategory(
    QuestionCategory category,
  ) async {
    final models = _box.values
        .where((model) => model.category == category)
        .toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get questions by role
  Future<List<Question>> getQuestionsByRole(Role role) async {
    final models = _box.values
        .where((model) => model.applicableRoles.contains(role))
        .toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get questions by difficulty level
  Future<List<Question>> getQuestionsByLevel(Level level) async {
    final models = _box.values
        .where((model) => model.difficulty == level)
        .toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get questions by role and level
  Future<List<Question>> getQuestionsByRoleAndLevel(
    Role role,
    Level level,
  ) async {
    final models = _box.values
        .where(
          (model) =>
              model.applicableRoles.contains(role) && model.difficulty == level,
        )
        .toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get questions by category and role
  Future<List<Question>> getQuestionsByCategoryAndRole(
    QuestionCategory category,
    Role role,
  ) async {
    final models = _box.values
        .where(
          (model) =>
              model.category == category &&
              model.applicableRoles.contains(role),
        )
        .toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get questions by category, role, and level
  Future<List<Question>> getQuestionsByCategoryRoleAndLevel(
    QuestionCategory category,
    Role role,
    Level level,
  ) async {
    final models = _box.values
        .where(
          (model) =>
              model.category == category &&
              model.applicableRoles.contains(role) &&
              model.difficulty == level,
        )
        .toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Search questions by text
  Future<List<Question>> searchQuestions(String searchText) async {
    final lowerSearchText = searchText.toLowerCase();
    final models = _box.values
        .where(
          (model) =>
              model.text.toLowerCase().contains(lowerSearchText) ||
              model.tags.any(
                (tag) => tag.toLowerCase().contains(lowerSearchText),
              ),
        )
        .toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get questions by tags
  Future<List<Question>> getQuestionsByTags(List<String> tags) async {
    final models = _box.values
        .where((model) => model.tags.any((tag) => tags.contains(tag)))
        .toList();
    return models.map((model) => model.toEntity()).toList();
  }

  /// Get random questions for a role and level
  Future<List<Question>> getRandomQuestions(
    Role role,
    Level level, {
    int count = 10,
  }) async {
    final models = _box.values
        .where(
          (model) =>
              model.applicableRoles.contains(role) && model.difficulty == level,
        )
        .toList();

    if (models.length <= count) {
      return models.map((model) => model.toEntity()).toList();
    }

    models.shuffle();
    return models.take(count).map((model) => model.toEntity()).toList();
  }

  /// Get total count of questions
  Future<int> getQuestionCount() async {
    return _box.length;
  }

  /// Get count of questions by category
  Future<int> getQuestionCountByCategory(QuestionCategory category) async {
    return _box.values.where((model) => model.category == category).length;
  }

  /// Get count of questions by role
  Future<int> getQuestionCountByRole(Role role) async {
    return _box.values
        .where((model) => model.applicableRoles.contains(role))
        .length;
  }

  /// Get count of questions by level
  Future<int> getQuestionCountByLevel(Level level) async {
    return _box.values.where((model) => model.difficulty == level).length;
  }

  /// Clear all questions (for testing or reset purposes)
  Future<void> clearAllQuestions() async {
    await _box.clear();
  }

  /// Check if question exists
  Future<bool> questionExists(String id) async {
    return _box.containsKey(id);
  }

  /// Bulk save questions (useful for initial data loading)
  Future<void> saveQuestions(List<Question> questions) async {
    final Map<String, QuestionModel> questionMap = {};
    for (final question in questions) {
      questionMap[question.id] = QuestionModel.fromEntity(question);
    }
    await _box.putAll(questionMap);
  }

  /// Close the data source
  Future<void> close() async {
    await _box.close();
  }
}
