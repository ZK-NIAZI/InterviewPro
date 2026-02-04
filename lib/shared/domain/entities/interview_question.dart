import 'package:equatable/equatable.dart';

/// Enhanced Interview Question entity for comprehensive question management
class InterviewQuestion extends Equatable {
  /// Unique identifier for the question
  final String id;

  /// The actual question text
  final String question;

  /// Category this question belongs to (technical, behavioral, leadership, role-specific)
  final String category;

  /// Difficulty level (beginner, intermediate, advanced)
  final String difficulty;

  /// Expected duration in minutes
  final int expectedDuration;

  /// Tags for categorization and filtering
  final List<String> tags;

  /// Sample answer or guidance for the interviewer
  final String? sampleAnswer;

  /// Evaluation criteria for scoring
  final List<String> evaluationCriteria;

  /// Role-specific identifier (optional, for role-specific questions)
  final String? roleSpecific;

  /// When this question was created
  final DateTime createdAt;

  /// When this question was last updated
  final DateTime updatedAt;

  /// Whether this question is active/enabled
  final bool isActive;

  const InterviewQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.difficulty,
    required this.expectedDuration,
    required this.tags,
    this.sampleAnswer,
    required this.evaluationCriteria,
    this.roleSpecific,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  /// Creates a copy of this question with updated fields
  InterviewQuestion copyWith({
    String? id,
    String? question,
    String? category,
    String? difficulty,
    int? expectedDuration,
    List<String>? tags,
    String? sampleAnswer,
    List<String>? evaluationCriteria,
    String? roleSpecific,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return InterviewQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      expectedDuration: expectedDuration ?? this.expectedDuration,
      tags: tags ?? this.tags,
      sampleAnswer: sampleAnswer ?? this.sampleAnswer,
      evaluationCriteria: evaluationCriteria ?? this.evaluationCriteria,
      roleSpecific: roleSpecific ?? this.roleSpecific,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Checks if this question matches the given difficulty level
  bool matchesDifficulty(String level) {
    return difficulty.toLowerCase() == level.toLowerCase();
  }

  /// Checks if this question is suitable for the given role
  bool isSuitableForRole(String? role) {
    if (role == null) return true;
    if (roleSpecific == null) return true;
    return roleSpecific!.toLowerCase().contains(role.toLowerCase()) ||
        role.toLowerCase().contains(roleSpecific!.toLowerCase());
  }

  /// Checks if this question contains any of the given tags
  bool hasAnyTag(List<String> searchTags) {
    return tags.any(
      (tag) => searchTags.any(
        (searchTag) => tag.toLowerCase().contains(searchTag.toLowerCase()),
      ),
    );
  }

  /// Checks if this question matches the search criteria
  bool matchesSearchCriteria({
    String? categoryFilter,
    String? difficultyFilter,
    String? roleFilter,
    List<String>? tagFilters,
  }) {
    if (categoryFilter != null &&
        category.toLowerCase() != categoryFilter.toLowerCase()) {
      return false;
    }

    if (difficultyFilter != null && !matchesDifficulty(difficultyFilter)) {
      return false;
    }

    if (roleFilter != null && !isSuitableForRole(roleFilter)) {
      return false;
    }

    if (tagFilters != null && tagFilters.isNotEmpty && !hasAnyTag(tagFilters)) {
      return false;
    }

    return isActive;
  }

  /// Gets a display-friendly category name
  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'technical':
        return 'Technical Skills';
      case 'behavioral':
        return 'Behavioral & Soft Skills';
      case 'leadership':
        return 'Leadership & Management';
      case 'role-specific':
        return 'Role-Specific Questions';
      default:
        return category;
    }
  }

  /// Gets a display-friendly difficulty name with color coding
  String get difficultyDisplayName {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return difficulty;
    }
  }

  /// Gets difficulty color for UI
  String get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return '#4CAF50'; // Green
      case 'intermediate':
        return '#FF9800'; // Orange
      case 'advanced':
        return '#F44336'; // Red
      default:
        return '#757575'; // Grey
    }
  }

  /// Converts to JSON for Appwrite storage
  Map<String, dynamic> toJson() {
    return {
      // Note: 'id' is not included here as Appwrite uses $id for document ID
      'question': question,
      'category': category,
      'difficulty': difficulty,
      'expectedDuration': expectedDuration,
      'tags': tags,
      'sampleAnswer': sampleAnswer,
      'evaluationCriteria': evaluationCriteria,
      'roleSpecific': roleSpecific,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Creates from JSON (from Appwrite)
  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      id: json['id'] ?? json['\$id'] ?? '',
      question: json['question'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? '',
      expectedDuration: json['expectedDuration'] ?? 5,
      tags: List<String>.from(json['tags'] ?? []),
      sampleAnswer: json['sampleAnswer'],
      evaluationCriteria: List<String>.from(json['evaluationCriteria'] ?? []),
      roleSpecific: json['roleSpecific'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    question,
    category,
    difficulty,
    expectedDuration,
    tags,
    sampleAnswer,
    evaluationCriteria,
    roleSpecific,
    createdAt,
    updatedAt,
    isActive,
  ];

  @override
  String toString() {
    return 'InterviewQuestion(id: $id, category: $category, difficulty: $difficulty, '
        'question: ${question.length > 50 ? '${question.substring(0, 50)}...' : question})';
  }
}
