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
    // In a real app, this would use SharedPreferences or similar
    // For now, settings persist during app session
    debugPrint(
      'Settings saved: notifications=$_notificationsEnabled, autoSave=$_autoSaveRecordings, language=$_selectedLanguage',
    );
  }

  /// Loads settings from persistent storage
  Future<void> loadSettings() async {
    // In a real app, this would load from SharedPreferences or similar
    // For now, using default values
    debugPrint('Settings loaded with default values');
  }
}
