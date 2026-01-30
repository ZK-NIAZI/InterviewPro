import 'package:flutter/material.dart';

/// Provider for managing settings state
class SettingsProvider extends ChangeNotifier {
  // Settings state
  bool _notificationsEnabled = true;
  bool _autoSaveRecordings = true;
  String _selectedLanguage = 'English';

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoSaveRecordings => _autoSaveRecordings;
  String get selectedLanguage => _selectedLanguage;

  /// Updates notifications setting and saves immediately
  void updateNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    _saveSettings();
    notifyListeners();
  }

  /// Updates auto-save recordings setting and saves immediately
  void updateAutoSaveRecordings(bool enabled) {
    _autoSaveRecordings = enabled;
    _saveSettings();
    notifyListeners();
  }

  /// Updates selected language and saves immediately
  void updateLanguage(String language) {
    _selectedLanguage = language;
    _saveSettings();
    notifyListeners();
  }

  /// Saves settings to persistent storage
  void _saveSettings() {
    // TODO: Implement actual settings persistence using SharedPreferences
    // For now, settings are saved in memory and will persist during app session
  }

  /// Loads settings from persistent storage
  Future<void> loadSettings() async {
    // TODO: Implement actual settings loading from SharedPreferences
    // For now, using default values
  }
}
