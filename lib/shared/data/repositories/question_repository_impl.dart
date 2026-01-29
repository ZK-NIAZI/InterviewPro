import '../../domain/entities/entities.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasources/question_local_datasource.dart';

/// Implementation of QuestionRepository using local data source
class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionLocalDataSource _localDataSource;

  QuestionRepositoryImpl(this._localDataSource);

  @override
  Future<List<Question>> getAllQuestions() async {
    return await _localDataSource.getAllQuestions();
  }

  @override
  Future<Question?> getQuestionById(String id) async {
    return await _localDataSource.getQuestionById(id);
  }

  @override
  Future<void> saveQuestion(Question question) async {
    await _localDataSource.saveQuestion(question);
  }

  @override
  Future<void> updateQuestion(Question question) async {
    await _localDataSource.updateQuestion(question);
  }

  @override
  Future<void> deleteQuestion(String id) async {
    await _localDataSource.deleteQuestion(id);
  }

  @override
  Future<List<Question>> getQuestionsByCategory(
    QuestionCategory category,
  ) async {
    return await _localDataSource.getQuestionsByCategory(category);
  }

  @override
  Future<List<Question>> getQuestionsByRole(Role role) async {
    return await _localDataSource.getQuestionsByRole(role);
  }

  @override
  Future<List<Question>> getQuestionsByLevel(Level level) async {
    return await _localDataSource.getQuestionsByLevel(level);
  }

  @override
  Future<List<Question>> getQuestionsByRoleAndLevel(
    Role role,
    Level level,
  ) async {
    return await _localDataSource.getQuestionsByRoleAndLevel(role, level);
  }

  @override
  Future<List<Question>> getQuestionsByCategoryAndRole(
    QuestionCategory category,
    Role role,
  ) async {
    return await _localDataSource.getQuestionsByCategoryAndRole(category, role);
  }

  @override
  Future<List<Question>> getQuestionsByCategoryRoleAndLevel(
    QuestionCategory category,
    Role role,
    Level level,
  ) async {
    return await _localDataSource.getQuestionsByCategoryRoleAndLevel(
      category,
      role,
      level,
    );
  }

  @override
  Future<List<Question>> searchQuestions(String searchText) async {
    return await _localDataSource.searchQuestions(searchText);
  }

  @override
  Future<List<Question>> getQuestionsByTags(List<String> tags) async {
    return await _localDataSource.getQuestionsByTags(tags);
  }

  @override
  Future<List<Question>> getRandomQuestions(
    Role role,
    Level level, {
    int count = 10,
  }) async {
    return await _localDataSource.getRandomQuestions(role, level, count: count);
  }

  @override
  Future<int> getQuestionCount() async {
    return await _localDataSource.getQuestionCount();
  }

  @override
  Future<int> getQuestionCountByCategory(QuestionCategory category) async {
    return await _localDataSource.getQuestionCountByCategory(category);
  }

  @override
  Future<int> getQuestionCountByRole(Role role) async {
    return await _localDataSource.getQuestionCountByRole(role);
  }

  @override
  Future<int> getQuestionCountByLevel(Level level) async {
    return await _localDataSource.getQuestionCountByLevel(level);
  }

  @override
  Future<bool> questionExists(String id) async {
    return await _localDataSource.questionExists(id);
  }

  @override
  Future<void> saveQuestions(List<Question> questions) async {
    await _localDataSource.saveQuestions(questions);
  }
}
