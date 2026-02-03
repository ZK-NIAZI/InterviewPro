import '../../domain/entities/role.dart';
import '../../domain/repositories/role_repository.dart';
import '../datasources/role_remote_datasource.dart';
import '../models/role_model.dart';

/// Implementation of RoleRepository using Appwrite
class RoleRepositoryImpl implements RoleRepository {
  final RoleRemoteDatasource _remoteDatasource;

  RoleRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<Role>> getRoles() async {
    try {
      final roleModels = await _remoteDatasource.getRoles();
      return roleModels.map(_mapModelToEntity).toList();
    } catch (e) {
      throw Exception('Failed to get roles: $e');
    }
  }

  @override
  Future<Role?> getRoleById(String id) async {
    try {
      final roleModel = await _remoteDatasource.getRoleById(id);
      return roleModel != null ? _mapModelToEntity(roleModel) : null;
    } catch (e) {
      throw Exception('Failed to get role by ID: $e');
    }
  }

  @override
  Future<Role> createRole(Role role) async {
    try {
      final roleModel = _mapEntityToModel(role);
      final createdModel = await _remoteDatasource.createRole(roleModel);
      return _mapModelToEntity(createdModel);
    } catch (e) {
      throw Exception('Failed to create role: $e');
    }
  }

  @override
  Future<Role> updateRole(Role role) async {
    try {
      final roleModel = _mapEntityToModel(role);
      final updatedModel = await _remoteDatasource.updateRole(roleModel);
      return _mapModelToEntity(updatedModel);
    } catch (e) {
      throw Exception('Failed to update role: $e');
    }
  }

  @override
  Future<void> deleteRole(String id) async {
    try {
      await _remoteDatasource.deleteRole(id);
    } catch (e) {
      throw Exception('Failed to delete role: $e');
    }
  }

  @override
  Future<bool> hasRoles() async {
    try {
      return await _remoteDatasource.hasRoles();
    } catch (e) {
      return false;
    }
  }

  /// Map RoleModel to Role entity
  Role _mapModelToEntity(RoleModel model) {
    return Role(
      id: model.id,
      name: model.name,
      icon: model.icon,
      description: model.description,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Map Role entity to RoleModel
  RoleModel _mapEntityToModel(Role entity) {
    return RoleModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      description: entity.description,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
