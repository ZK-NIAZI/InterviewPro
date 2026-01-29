import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Core Question entity representing an interview question
class Question extends Equatable {
  /// Unique identifier for the question
  final String id;

  /// The actual question text
  final String text;

  /// Category this question belongs to
  final QuestionCategory category;

  /// List of roles this question is applicable for
  final List<Role> applicableRoles;

  /// Difficulty level of the question
  final Level difficulty;

  /// Expected answer or guidance for the interviewer (optional)
  final String? expectedAnswer;

  /// Tags for additional categorization and filtering
  final List<String> tags;

  const Question({
    required this.id,
    required this.text,
    required this.category,
    required this.applicableRoles,
    required this.difficulty,
    this.expectedAnswer,
    required this.tags,
  });

  /// Creates a copy of this question with updated fields
  Question copyWith({
    String? id,
    String? text,
    QuestionCategory? category,
    List<Role>? applicableRoles,
    Level? difficulty,
    String? expectedAnswer,
    List<String>? tags,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      applicableRoles: applicableRoles ?? this.applicableRoles,
      difficulty: difficulty ?? this.difficulty,
      expectedAnswer: expectedAnswer ?? this.expectedAnswer,
      tags: tags ?? this.tags,
    );
  }

  /// Checks if this question is applicable for the given role
  bool isApplicableForRole(Role role) {
    return applicableRoles.contains(role);
  }

  /// Checks if this question matches the given difficulty level
  bool matchesDifficulty(Level level) {
    return difficulty == level;
  }

  /// Checks if this question is suitable for the given role and level
  bool isSuitableFor(Role role, Level level) {
    return isApplicableForRole(role) && matchesDifficulty(level);
  }

  /// Checks if this question contains any of the given tags
  bool hasAnyTag(List<String> searchTags) {
    return tags.any((tag) => searchTags.contains(tag));
  }

  /// Gets a display-friendly category name
  String get categoryDisplayName {
    switch (category) {
      case QuestionCategory.programmingFundamentals:
        return 'Programming Fundamentals';
      case QuestionCategory.roleSpecificTechnical:
        return 'Role-Specific Technical';
      case QuestionCategory.modernDevelopmentPractices:
        return 'Modern Development Practices';
      case QuestionCategory.softSkills:
        return 'Soft Skills';
    }
  }

  /// Gets a display-friendly difficulty name
  String get difficultyDisplayName {
    switch (difficulty) {
      case Level.intern:
        return 'Intern';
      case Level.associate:
        return 'Associate';
      case Level.senior:
        return 'Senior';
    }
  }

  @override
  List<Object?> get props => [
    id,
    text,
    category,
    applicableRoles,
    difficulty,
    expectedAnswer,
    tags,
  ];

  @override
  String toString() {
    return 'Question(id: $id, category: $category, difficulty: $difficulty, '
        'applicableRoles: $applicableRoles, text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...)';
  }
}
