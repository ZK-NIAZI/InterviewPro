import '../../domain/entities/experience_level.dart';
import '../../domain/repositories/experience_level_repository.dart';
import '../datasources/experience_level_remote_datasource.dart';
import '../models/experience_level_model.dart';

/// Implementation of experience level repository
class ExperienceLevelRepositoryImpl implements ExperienceLevelRepository {
  final ExperienceLevelRemoteDatasource _remoteDatasource;

  ExperienceLevelRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<ExperienceLevel>> getExperienceLevels() async {
    try {
      final models = await _remoteDatasource.getExperienceLevels();
      return models.map((model) => model.toEntity()).toList();
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
      final model = await _remoteDatasource.createExperienceLevel(
        title: title,
        description: description,
        sortOrder: sortOrder,
      );
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to create experience level: $e');
    }
  }

  @override
  Future<ExperienceLevel> updateExperienceLevel(
    ExperienceLevel experienceLevel,
  ) async {
    try {
      final model = await _remoteDatasource.updateExperienceLevel(
        ExperienceLevelModel.fromEntity(experienceLevel),
      );
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to update experience level: $e');
    }
  }

  @override
  Future<void> deleteExperienceLevel(String id) async {
    try {
      await _remoteDatasource.deleteExperienceLevel(id);
    } catch (e) {
      throw Exception('Failed to delete experience level: $e');
    }
  }

  @override
  Future<bool> hasExperienceLevels() async {
    try {
      return await _remoteDatasource.hasExperienceLevels();
    } catch (e) {
      return false;
    }
  }
}
