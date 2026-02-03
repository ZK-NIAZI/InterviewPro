import 'package:flutter/foundation.dart';

/// Base provider class with common functionality for backend providers
abstract class BaseProvider<T> extends ChangeNotifier {
  List<T> _items = [];
  bool _isLoading = false;
  String? _error;
  bool _hasTriedBackend = false;

  // Getters
  List<T> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasTriedBackend => _hasTriedBackend;

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Set items and notify listeners
  void setItems(List<T> items) {
    _items = items;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Mark backend as tried
  void markBackendTried() {
    _hasTriedBackend = true;
  }

  /// Reset backend tried flag
  void resetBackendTried() {
    _hasTriedBackend = false;
  }

  /// Load items with fallback pattern
  Future<void> loadItemsWithFallback({
    required Future<void> Function() loadFromBackend,
    required void Function() loadFallback,
  }) async {
    if (_isLoading) return;

    setLoading(true);
    setError(null);

    try {
      await loadFromBackend();
    } catch (e) {
      debugPrint('❌ Backend error: $e');
      setError(e.toString());
      loadFallback();
    } finally {
      setLoading(false);
    }
  }

  /// Load items in background without blocking UI
  void loadItemsInBackground({
    required void Function() loadFallback,
    required Future<void> Function() loadFromBackend,
  }) {
    if (_hasTriedBackend || _isLoading) return;

    // Start with fallback items immediately
    loadFallback();

    // Try to load from backend in background
    Future.delayed(Duration.zero, () async {
      try {
        await loadFromBackend();
      } catch (e) {
        debugPrint('⏰ Background connection timeout, keeping fallback items');
      }
    });
  }
}
