import 'package:appwrite/appwrite.dart';
import '../config/appwrite_config.dart';

/// Appwrite service for managing backend operations
class AppwriteService {
  static AppwriteService? _instance;
  late Client _client;
  late Databases _databases;
  late Account _account;

  AppwriteService._internal();

  static AppwriteService get instance {
    _instance ??= AppwriteService._internal();
    return _instance!;
  }

  /// Initialize Appwrite client
  void initialize() {
    _client = Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId);

    _databases = Databases(_client);
    _account = Account(_client);
  }

  /// Get databases instance
  Databases get databases => _databases;

  /// Get account instance
  Account get account => _account;

  /// Get client instance
  Client get client => _client;

  /// Get database ID for collections
  String get databaseId => AppwriteConfig.databaseId;

  /// Update interview with Google Drive file info
  Future<void> updateInterviewDriveInfo({
    required String interviewId,
    required String driveFileId,
    required String driveFileUrl,
  }) async {
    try {
      await _databases.updateDocument(
        databaseId: databaseId,
        collectionId: AppwriteConfig.interviewsCollectionId,
        documentId: interviewId,
        data: {'driveFileId': driveFileId, 'driveFileUrl': driveFileUrl},
      );
      print('✅ Updated interview $interviewId with Drive info');
    } catch (e) {
      print('❌ Failed to update interview with Drive info: $e');
      rethrow;
    }
  }
}
