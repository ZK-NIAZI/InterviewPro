import 'package:appwrite/appwrite.dart';
import '../../../core/config/appwrite_config.dart';
import '../../../core/services/appwrite_service.dart';
import '../models/role_model.dart';

/// Remote datasource for Role operations using Appwrite
class RoleRemoteDatasource {
  final AppwriteService _appwriteService;

  RoleRemoteDatasource(this._appwriteService);

  /// Get all active roles from Appwrite
  Future<List<RoleModel>> getRoles() async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.rolesCollectionId,
        queries: [Query.equal('isActive', true), Query.orderAsc('name')],
      );

      return response.documents
          .map((doc) => RoleModel.fromDocument(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch roles: $e');
    }
  }

  /// Get role by ID from Appwrite
  Future<RoleModel?> getRoleById(String id) async {
    try {
      final response = await _appwriteService.databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.rolesCollectionId,
        documentId: id,
      );

      return RoleModel.fromDocument(response.data);
    } catch (e) {
      if (e is AppwriteException && e.code == 404) {
        return null;
      }
      throw Exception('Failed to fetch role: $e');
    }
  }

  /// Create a new role in Appwrite
  Future<RoleModel> createRole(RoleModel role) async {
    try {
      final response = await _appwriteService.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.rolesCollectionId,
        documentId: ID.unique(),
        data: role.toDocument(),
      );

      return RoleModel.fromDocument(response.data);
    } catch (e) {
      throw Exception('Failed to create role: $e');
    }
  }

  /// Update existing role in Appwrite
  Future<RoleModel> updateRole(RoleModel role) async {
    try {
      final response = await _appwriteService.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.rolesCollectionId,
        documentId: role.id,
        data: role.toDocument(),
      );

      return RoleModel.fromDocument(response.data);
    } catch (e) {
      throw Exception('Failed to update role: $e');
    }
  }

  /// Delete role from Appwrite
  Future<void> deleteRole(String id) async {
    try {
      await _appwriteService.databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.rolesCollectionId,
        documentId: id,
      );
    } catch (e) {
      throw Exception('Failed to delete role: $e');
    }
  }

  /// Check if any roles exist in the collection
  Future<bool> hasRoles() async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.rolesCollectionId,
        queries: [Query.limit(1)],
      );

      return response.documents.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
