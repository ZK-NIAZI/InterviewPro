import 'package:flutter/material.dart';
import '../../../../core/config/appwrite_config.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/cache_manager.dart';
import '../../../../core/utils/retry_helper.dart';
import '../../../../shared/domain/entities/role.dart';
import '../../../../shared/domain/repositories/role_repository.dart';

/// Provider for managing roles from Appwrite backend
class RoleProvider extends ChangeNotifier {
  final RoleRepository _roleRepository = sl<RoleRepository>();

  List<Role> _roles = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedRoleId;

  // Getters
  List<Role> get roles => _roles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedRoleId => _selectedRoleId;
  Role? get selectedRole => _selectedRoleId != null
      ? _roles.firstWhere(
          (role) => role.id == _selectedRoleId,
          orElse: () => _roles.first,
        )
      : null;

  /// Load roles from Appwrite backend
  Future<void> loadRoles() async {
    _setLoading(true);
    _error = null;

    // Try to get from cache first
    final cachedRoles = CacheManager.get<List<Role>>(CacheManager.rolesKey);
    if (cachedRoles != null && cachedRoles.isNotEmpty) {
      debugPrint('✅ Using cached roles (${cachedRoles.length} items)');
      _roles = cachedRoles;
      _setLoading(false);
      return;
    }

    // Always start with fallback roles for immediate UI response
    _createFallbackRoles();

    // Then try to load from backend in the background
    if (AppwriteConfig.isConfigured) {
      _loadFromBackendInBackground();
    } else {
      debugPrint('⚠️ Appwrite not configured, using fallback roles only');
    }

    _setLoading(false);
  }

  /// Load roles from backend in background without blocking UI
  Future<void> _loadFromBackendInBackground() async {
    try {
      debugPrint('🔧 Attempting to connect to Appwrite in background...');
      debugPrint('Project ID: ${AppwriteConfig.projectId}');
      debugPrint('Endpoint: ${AppwriteConfig.endpoint}');

      // Set a timeout for network operations
      await _loadFromBackend().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⏰ Background connection timeout, keeping fallback roles');
        },
      );
    } catch (e) {
      debugPrint('❌ Background loading failed: $e');
      debugPrint('🔄 Keeping fallback roles');
    }
  }

  /// Load roles from backend with proper error handling
  Future<void> _loadFromBackend() async {
    await RetryHelper.withRetry(
      () async {
        // Check if roles exist in backend
        final hasRoles = await _roleRepository.hasRoles();

        if (!hasRoles) {
          debugPrint('📝 No roles found, creating default roles...');
          // Create default roles if none exist
          await _createDefaultRoles();
        }

        // Fetch roles from backend
        debugPrint('📥 Fetching roles from backend...');
        final backendRoles = await _roleRepository.getRoles();

        if (backendRoles.isNotEmpty) {
          debugPrint(
            '✅ Successfully loaded ${backendRoles.length} roles from backend',
          );
          _roles = backendRoles;

          // Cache the roles
          CacheManager.set(
            CacheManager.rolesKey,
            backendRoles,
            CacheManager.rolesTTL,
          );

          notifyListeners(); // Update UI with backend data
        } else {
          debugPrint('⚠️ No roles returned from backend, keeping fallback');
        }
      },
      config: RetryHelper.networkConfig,
      shouldRetry: RetryHelper.isRetryableError,
    );
  }

  /// Select a role by ID
  void selectRole(String roleId) {
    if (_roles.any((role) => role.id == roleId) && _selectedRoleId != roleId) {
      _selectedRoleId = roleId;
      notifyListeners();
    }
  }

  /// Clear selected role
  void clearSelection() {
    if (_selectedRoleId != null) {
      _selectedRoleId = null;
      notifyListeners();
    }
  }

  /// Create default roles in Appwrite backend
  Future<void> _createDefaultRoles() async {
    final defaultRoles = [
      Role(
        id: '',
        name: 'Flutter Developer',
        icon: 'flutter',
        description: 'Mobile app development with Flutter framework',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Role(
        id: '',
        name: 'UI/UX Designer',
        icon: 'design_services',
        description: 'User interface and experience design',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Role(
        id: '',
        name: 'Product Manager',
        icon: 'business_center',
        description: 'Product strategy and management',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Role(
        id: '',
        name: 'Backend Engineer',
        icon: 'storage',
        description: 'Server-side development and APIs',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Role(
        id: '',
        name: 'QA Engineer',
        icon: 'bug_report',
        description: 'Quality assurance and testing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Role(
        id: '',
        name: 'HR Specialist',
        icon: 'people',
        description: 'Human resources and talent management',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final role in defaultRoles) {
      try {
        await _roleRepository.createRole(role);
      } catch (e) {
        debugPrint('Failed to create role ${role.name}: $e');
      }
    }
  }

  /// Create fallback roles when backend is unavailable
  void _createFallbackRoles() {
    _roles = [
      Role(
        id: 'flutter_dev',
        name: 'Flutter Developer',
        icon: 'flutter',
        description: 'Mobile app development with Flutter framework',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Role(
        id: 'ui_ux_designer',
        name: 'UI/UX Designer',
        icon: 'design_services',
        description: 'User interface and experience design',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Role(
        id: 'product_manager',
        name: 'Product Manager',
        icon: 'business_center',
        description: 'Product strategy and management',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Role(
        id: 'backend_engineer',
        name: 'Backend Engineer',
        icon: 'storage',
        description: 'Server-side development and APIs',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Role(
        id: 'qa_engineer',
        name: 'QA Engineer',
        icon: 'bug_report',
        description: 'Quality assurance and testing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Role(
        id: 'hr_specialist',
        name: 'HR Specialist',
        icon: 'people',
        description: 'Human resources and talent management',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Refresh roles from backend
  Future<void> refreshRoles() async {
    // Clear cache to force fresh data
    CacheManager.remove(CacheManager.rolesKey);
    await loadRoles();
  }

  @override
  void dispose() {
    // Cancel any pending operations
    super.dispose();
  }
}
