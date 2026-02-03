import 'package:flutter/material.dart';
import 'appwrite_config.dart';

/// Configuration validator for Appwrite setup
class ConfigValidator {
  /// Validate the current Appwrite configuration
  static ConfigValidationResult validate() {
    final projectId = AppwriteConfig.projectId;
    final endpoint = AppwriteConfig.endpoint;

    // Check if project ID is set
    if (projectId == 'YOUR_PROJECT_ID_HERE') {
      return ConfigValidationResult(
        isValid: false,
        message: 'Project ID not configured',
        details:
            'Please update your Project ID in lib/core/config/setup_helper.dart',
        action: 'Find your Project ID in the Appwrite console dashboard',
      );
    }

    // Check if project ID looks valid (basic format check)
    if (projectId.length < 10) {
      return ConfigValidationResult(
        isValid: false,
        message: 'Invalid Project ID format',
        details:
            'Project ID should be a longer string (e.g., 67a1b2c3d4e5f6789abc)',
        action: 'Copy the exact Project ID from your Appwrite console',
      );
    }

    // Check endpoint
    if (!endpoint.startsWith('https://') ||
        !endpoint.contains('cloud.appwrite.io/v1')) {
      return ConfigValidationResult(
        isValid: false,
        message: 'Incorrect endpoint',
        details: 'Endpoint should be https://[region.]cloud.appwrite.io/v1',
        action: 'Update the endpoint in appwrite_config.dart',
      );
    }

    return ConfigValidationResult(
      isValid: true,
      message: 'Configuration looks good!',
      details: 'Project ID: $projectId\nEndpoint: $endpoint',
      action: 'Test the connection by running the app',
    );
  }

  /// Show configuration status dialog
  static void showConfigDialog(BuildContext context) {
    final result = validate();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.isValid ? Icons.check_circle : Icons.error,
              color: result.isValid ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(result.message),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.details),
            const SizedBox(height: 16),
            Text('Next Step:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(result.action),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Result of configuration validation
class ConfigValidationResult {
  final bool isValid;
  final String message;
  final String details;
  final String action;

  ConfigValidationResult({
    required this.isValid,
    required this.message,
    required this.details,
    required this.action,
  });
}
