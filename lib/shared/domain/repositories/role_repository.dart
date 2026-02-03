import '../entities/role.dart';

/// Repository interface for Role operations
abstract class RoleRepository {
  /// Get all active roles from backend
  Future<List<Role>> getRoles();

  /// Get role by ID
  Future<Role?> getRoleById(String id);

  /// Create a new role
  Future<Role> createRole(Role role);

  /// Update existing role
  Future<Role> updateRole(Role role);

  /// Delete role by ID
  Future<void> deleteRole(String id);

  /// Check if roles exist in backend
  Future<bool> hasRoles();
}
