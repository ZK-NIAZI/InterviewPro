import 'package:appwrite/appwrite.dart';
import '../../../core/services/appwrite_service.dart';
import '../models/experience_level_model.dart';

/// Remote datasource for experience level operations using Appwrite
class ExperienceLevelRemoteDatasource {
  final AppwriteService _appwriteService;
  static const String _collectionId = 'experience_levels';

  ExperienceLevelRemoteDatasource(this._appwriteService);

  /// Get all experience levels from Appwrite
  Future<List<ExperienceLevelModel>> getExperienceLevels() async {
    try {
      final databases = _appwriteService.databases;
      final response = await databases.listDocuments(
        databaseId: _appwriteService.databaseId,
        collectionId: _collectionId,
        queries: [Query.equal('isActive', true), Query.orderAsc('sortOrder')],
      );

      return response.documents
          .map((doc) => ExperienceLevelModel.fromDocument(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch experience levels: $e');
    }
  }

  /// Create a new experience level in Appwrite
  Future<ExperienceLevelModel> createExperienceLevel({
    required String title,
    required String description,
    required int sortOrder,
  }) async {
    try {
      final databases = _appwriteService.databases;
      final document = await databases.createDocument(
        databaseId: _appwriteService.databaseId,
        collectionId: _collectionId,
        documentId: ID.unique(),
        data: {
          'title': title,
          'description': description,
          'sortOrder': sortOrder,
          'isActive': true,
        },
      );

      return ExperienceLevelModel.fromDocument(document.data);
    } catch (e) {
      throw Exception('Failed to create experience level: $e');
    }
  }

  /// Update an existing experience level in Appwrite
  Future<ExperienceLevelModel> updateExperienceLevel(
    ExperienceLevelModel experienceLevel,
  ) async {
    try {
      final databases = _appwriteService.databases;
      final document = await databases.updateDocument(
        databaseId: _appwriteService.databaseId,
        collectionId: _collectionId,
        documentId: experienceLevel.id,
        data: experienceLevel.toDocument(),
      );

      return ExperienceLevelModel.fromDocument(document.data);
    } catch (e) {
      throw Exception('Failed to update experience level: $e');
    }
  }

  /// Delete an experience level from Appwrite
  Future<void> deleteExperienceLevel(String id) async {
    try {
      final databases = _appwriteService.databases;
      await databases.deleteDocument(
        databaseId: _appwriteService.databaseId,
        collectionId: _collectionId,
        documentId: id,
      );
    } catch (e) {
      throw Exception('Failed to delete experience level: $e');
    }
  }

  /// Check if experience levels exist in Appwrite
  Future<bool> hasExperienceLevels() async {
    try {
      final databases = _appwriteService.databases;
      final response = await databases.listDocuments(
        databaseId: _appwriteService.databaseId,
        collectionId: _collectionId,
        queries: [Query.equal('isActive', true), Query.limit(1)],
      );

      return response.documents.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
