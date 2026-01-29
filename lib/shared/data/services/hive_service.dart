import 'package:hive_flutter/hive_flutter.dart';
import '../models/interview_model.dart';
import '../models/question_model.dart';
import '../models/question_response_model.dart';
import '../models/enum_adapters.dart';

/// Service for initializing and managing Hive database
class HiveService {
  static bool _isInitialized = false;

  /// Initialize Hive with all adapters and boxes
  static Future<void> init() async {
    if (_isInitialized) return;

    // Initialize Hive
    await Hive.initFlutter();

    // Register enum adapters
    Hive.registerAdapter(RoleAdapter());
    Hive.registerAdapter(LevelAdapter());
    Hive.registerAdapter(QuestionCategoryAdapter());
    Hive.registerAdapter(InterviewStatusAdapter());

    // Register model adapters (these will be generated)
    Hive.registerAdapter(InterviewModelAdapter());
    Hive.registerAdapter(QuestionModelAdapter());
    Hive.registerAdapter(QuestionResponseModelAdapter());

    _isInitialized = true;
  }

  /// Close all Hive boxes
  static Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
  }

  /// Clear all data (for testing purposes)
  static Future<void> clearAllData() async {
    await Hive.deleteFromDisk();
    _isInitialized = false;
  }

  /// Check if Hive is initialized
  static bool get isInitialized => _isInitialized;

  /// Get box names
  static const String interviewsBoxName = 'interviews';
  static const String questionsBoxName = 'questions';
}
