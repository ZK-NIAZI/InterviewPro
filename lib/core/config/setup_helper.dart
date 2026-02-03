/// Setup helper for configuring Appwrite
class SetupHelper {
  /// Your actual Appwrite Project ID
  static const String projectId = 'interviewpro';

  /// Validate if setup is complete
  static bool get isSetupComplete => projectId != 'YOUR_PROJECT_ID_HERE';

  /// Get setup status message
  static String get setupStatusMessage => isSetupComplete
      ? 'Appwrite configuration complete ✅'
      : 'Please update your Project ID in lib/core/config/setup_helper.dart';
}
