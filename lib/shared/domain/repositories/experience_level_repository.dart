import '../entities/experience_level.dart';

/// Repository interface for experience level operations
abstract class ExperienceLevelRepository {
  /// Get all experience levels from the backend
  Future<List<ExperienceLevel>> getExperienceLevels();

  /// Create a new experience level
  Future<ExperienceLevel> createExperienceLevel({
    required String title,
    required String description,
    required int sortOrder,
  });

  /// Update an existing experience level
  Future<ExperienceLevel> updateExperienceLevel(
    ExperienceLevel experienceLevel,
  );

  /// Delete an experience level
  Future<void> deleteExperienceLevel(String id);

  /// Check if experience levels exist in the backend
  Future<bool> hasExperienceLevels();
}
