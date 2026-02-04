import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'platform_mock_helper.dart';

void main() {
  group('Platform Mock Helper Tests', () {
    setUp(() {
      PlatformMockHelper.setupMocks();
    });

    tearDown(() {
      PlatformMockHelper.teardownMocks();
    });

    test('should mock path_provider methods correctly', () async {
      const platform = MethodChannel('plugins.flutter.io/path_provider');

      // Test getApplicationDocumentsDirectory
      final documentsDir = await platform.invokeMethod(
        'getApplicationDocumentsDirectory',
      );
      expect(documentsDir, equals('/tmp/test_documents'));

      // Test getTemporaryDirectory
      final tempDir = await platform.invokeMethod('getTemporaryDirectory');
      expect(tempDir, equals('/tmp/test_temp'));

      // Test getApplicationSupportDirectory
      final supportDir = await platform.invokeMethod(
        'getApplicationSupportDirectory',
      );
      expect(supportDir, equals('/tmp/test_support'));
    });

    test('should mock device_info_plus correctly', () async {
      const platform = MethodChannel('dev.fluttercommunity.plus/device_info');

      final deviceInfo = await platform.invokeMethod('getDeviceInfo');
      expect(deviceInfo, isA<Map>());
      expect(deviceInfo['model'], equals('Test Device'));
      expect(deviceInfo['manufacturer'], equals('Test Manufacturer'));
    });

    test('should mock package_info_plus correctly', () async {
      const platform = MethodChannel('dev.fluttercommunity.plus/package_info');

      final packageInfo = await platform.invokeMethod('getAll');
      expect(packageInfo, isA<Map>());
      expect(packageInfo['appName'], equals('Test App'));
      expect(packageInfo['packageName'], equals('com.test.app'));
      expect(packageInfo['version'], equals('1.0.0'));
    });

    test('should handle custom mock setup', () async {
      const customChannel = 'test.custom.channel';

      PlatformMockHelper.setupCustomMock(customChannel, (
        MethodCall methodCall,
      ) async {
        if (methodCall.method == 'testMethod') {
          return 'test_result';
        }
        return null;
      });

      const platform = MethodChannel(customChannel);
      final result = await platform.invokeMethod('testMethod');
      expect(result, equals('test_result'));

      // Cleanup
      PlatformMockHelper.teardownCustomMock(customChannel);
    });
  });
}
