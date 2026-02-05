import '../../domain/entities/experience_level.dart';
import '../../domain/repositories/experience_level_repository.dart';

/// Implementation of experience level repository using direct entities
class ExperienceLevelRepositoryImpl implements ExperienceLevelRepository {
  ExperienceLevelRepositoryImpl();

  @override
  Future<List<ExperienceLevel>> getExperienceLevels() async {
    try {
      final now = DateTime.now();
      // Return predefined experience levels for production
      return [
        ExperienceLevel(
          id: 'intern',
          title: 'Intern',
          description: 'Entry-level position for students or recent graduates',
          sortOrder: 1,
          createdAt: now,
          updatedAt: now,
        ),
        ExperienceLevel(
          id: 'associate',
          title: 'Associate',
          description: 'Mid-level position with 1-3 years of experience',
          sortOrder: 2,
          createdAt: now,
          updatedAt: now,
        ),
        ExperienceLevel(
          id: 'senior',
          title: 'Senior',
          description: 'Senior-level position with 3+ years of experience',
          sortOrder: 3,
          createdAt: now,
          updatedAt: now,
        ),
      ];
    } catch (e) {
      throw Exception('Failed to get experience levels: $e');
    }
  }

  @override
  Future<ExperienceLevel> createExperienceLevel({
    required String title,
    required String description,
    required int sortOrder,
  }) async {
    try {
      final now = DateTime.now();
      // For production, return a new experience level
      return ExperienceLevel(
        id: 'custom_${now.millisecondsSinceEpoch}',
        title: title,
        description: description,
        sortOrder: sortOrder,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to create experience level: $e');
    }
  }

  @override
  Future<ExperienceLevel> updateExperienceLevel(
    ExperienceLevel experienceLevel,
  ) async {
    try {
      // For production, return the updated experience level
      return experienceLevel;
    } catch (e) {
      throw Exception('Failed to update experience level: $e');
    }
  }

  @override
  Future<void> deleteExperienceLevel(String id) async {
    try {
      // For production, this would delete from backend
      // Currently a no-op for predefined levels
    } catch (e) {
      throw Exception('Failed to delete experience level: $e');
    }
  }

  @override
  Future<bool> hasExperienceLevels() async {
    try {
      return true; // Always have predefined levels
    } catch (e) {
      return false;
    }
  }
}
