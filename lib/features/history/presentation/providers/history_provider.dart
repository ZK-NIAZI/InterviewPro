import 'package:flutter/material.dart';

/// Provider for managing interview history state
class HistoryProvider extends ChangeNotifier {
  bool _isLoading = false;
  int _selectedFilterIndex = 0;

  // Getters
  bool get isLoading => _isLoading;
  int get selectedFilterIndex => _selectedFilterIndex;

  /// Sets the loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Updates the selected filter index
  void updateFilter(int index) {
    _selectedFilterIndex = index;
    notifyListeners();
  }

  /// Loads interview history data
  Future<void> loadHistoryData() async {
    setLoading(true);

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    setLoading(false);
  }

  /// Refreshes the interview history data
  Future<void> refreshData() async {
    await loadHistoryData();
  }
}
