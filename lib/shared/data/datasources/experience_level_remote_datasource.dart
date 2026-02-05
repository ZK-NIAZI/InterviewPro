import '../../domain/entities/experience_level.dart';

/// Remote datasource for experience levels using direct entities
abstract class ExperienceLevelRemoteDatasource {
  Future<List<ExperienceLevel>> getExperienceLevels();
  Future<ExperienceLevel> createExperienceLevel({
    required String title,
    required String description,
    required int sortOrder,
  });
  Future<ExperienceLevel> updateExperienceLevel(
    ExperienceLevel experienceLevel,
  );
  Future<void> deleteExperienceLevel(String id);
  Future<bool> hasExperienceLevels();
}

/// Implementation of experience level remote datasource
class ExperienceLevelRemoteDatasourceImpl
    implements ExperienceLevelRemoteDatasource {
  @override
  Future<List<ExperienceLevel>> getExperienceLevels() async {
    final now = DateTime.now();
    // Return predefined experience levels
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
  }

  @override
  Future<ExperienceLevel> createExperienceLevel({
    required String title,
    required String description,
    required int sortOrder,
  }) async {
    final now = DateTime.now();
    return ExperienceLevel(
      id: 'custom_${now.millisecondsSinceEpoch}',
      title: title,
      description: description,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<ExperienceLevel> updateExperienceLevel(
    ExperienceLevel experienceLevel,
  ) async {
    return experienceLevel;
  }

  @override
  Future<void> deleteExperienceLevel(String id) async {
    // No-op for predefined levels
  }

  @override
  Future<bool> hasExperienceLevels() async {
    return true;
  }
}
