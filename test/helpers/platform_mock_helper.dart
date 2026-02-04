import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for mocking platform-specific functionality in tests
class PlatformMockHelper {
  /// Setup all platform mocks needed for testing
  static void setupMocks() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock path_provider plugin
    _setupPathProviderMock();

    // Mock other platform channels as needed
    _setupOtherMocks();
  }

  /// Teardown all platform mocks
  static void teardownMocks() {
    // Reset path_provider mock
    const MethodChannel(
      'plugins.flutter.io/path_provider',
    ).setMockMethodCallHandler(null);

    // Reset other mocks
    _teardownOtherMocks();
  }

  /// Setup path_provider mock for file system operations
  static void _setupPathProviderMock() {
    const MethodChannel(
      'plugins.flutter.io/path_provider',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getApplicationDocumentsDirectory':
          return '/tmp/test_documents';
        case 'getTemporaryDirectory':
          return '/tmp/test_temp';
        case 'getApplicationSupportDirectory':
          return '/tmp/test_support';
        case 'getLibraryDirectory':
          return '/tmp/test_library';
        case 'getExternalStorageDirectory':
          return '/tmp/test_external';
        case 'getExternalCacheDirectories':
          return ['/tmp/test_external_cache'];
        case 'getExternalStorageDirectories':
          return ['/tmp/test_external_storage'];
        case 'getDownloadsDirectory':
          return '/tmp/test_downloads';
        default:
          return null;
      }
    });
  }

  /// Setup other platform mocks (can be extended as needed)
  static void _setupOtherMocks() {
    // Mock device_info_plus if needed
    const MethodChannel(
      'dev.fluttercommunity.plus/device_info',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getDeviceInfo':
          return {
            'model': 'Test Device',
            'manufacturer': 'Test Manufacturer',
            'version': '1.0.0',
          };
        default:
          return null;
      }
    });

    // Mock package_info_plus if needed
    const MethodChannel(
      'dev.fluttercommunity.plus/package_info',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getAll':
          return {
            'appName': 'Test App',
            'packageName': 'com.test.app',
            'version': '1.0.0',
            'buildNumber': '1',
          };
        default:
          return null;
      }
    });
  }

  /// Teardown other platform mocks
  static void _teardownOtherMocks() {
    const MethodChannel(
      'dev.fluttercommunity.plus/device_info',
    ).setMockMethodCallHandler(null);
    const MethodChannel(
      'dev.fluttercommunity.plus/package_info',
    ).setMockMethodCallHandler(null);
  }

  /// Setup mock for a specific method channel
  static void setupCustomMock(
    String channelName,
    Future<dynamic> Function(MethodCall) handler,
  ) {
    MethodChannel(channelName).setMockMethodCallHandler(handler);
  }

  /// Teardown mock for a specific method channel
  static void teardownCustomMock(String channelName) {
    MethodChannel(channelName).setMockMethodCallHandler(null);
  }
}
