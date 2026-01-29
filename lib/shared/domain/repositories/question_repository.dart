import '../entities/entities.dart';

/// Repository interface for managing question data
abstract class QuestionRepository {
  /// Get all questions
  Future<List<Question>> getAllQuestions();

  /// Get question by ID
  Future<Question?> getQuestionById(String id);

  /// Save question
  Future<void> saveQuestion(Question question);

  /// Update question
  Future<void> updateQuestion(Question question);

  /// Delete question
  Future<void> deleteQuestion(String id);

  /// Get questions by category
  Future<List<Question>> getQuestionsByCategory(QuestionCategory category);

  /// Get questions by role
  Future<List<Question>> getQuestionsByRole(Role role);

  /// Get questions by difficulty level
  Future<List<Question>> getQuestionsByLevel(Level level);

  /// Get questions by role and level
  Future<List<Question>> getQuestionsByRoleAndLevel(Role role, Level level);

  /// Get questions by category and role
  Future<List<Question>> getQuestionsByCategoryAndRole(
    QuestionCategory category,
    Role role,
  );

  /// Get questions by category, role, and level
  Future<List<Question>> getQuestionsByCategoryRoleAndLevel(
    QuestionCategory category,
    Role role,
    Level level,
  );

  /// Search questions by text
  Future<List<Question>> searchQuestions(String searchText);

  /// Get questions by tags
  Future<List<Question>> getQuestionsByTags(List<String> tags);

  /// Get random questions for a role and level
  Future<List<Question>> getRandomQuestions(
    Role role,
    Level level, {
    int count = 10,
  });

  /// Get total count of questions
  Future<int> getQuestionCount();

  /// Get count of questions by category
  Future<int> getQuestionCountByCategory(QuestionCategory category);

  /// Get count of questions by role
  Future<int> getQuestionCountByRole(Role role);

  /// Get count of questions by level
  Future<int> getQuestionCountByLevel(Level level);

  /// Check if question exists
  Future<bool> questionExists(String id);

  /// Bulk save questions (useful for initial data loading)
  Future<void> saveQuestions(List<Question> questions);
}
