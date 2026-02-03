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
}
