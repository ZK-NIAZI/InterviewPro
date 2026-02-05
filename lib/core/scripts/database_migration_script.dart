import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../services/service_locator.dart';
import '../../shared/data/datasources/interview_question_remote_datasource.dart';
import '../../shared/domain/entities/interview_question.dart';

/// Database migration script to upload questions from JSON to Appwrite
class DatabaseMigrationScript {
  final InterviewQuestionRemoteDatasource _datasource;

  DatabaseMigrationScript(this._datasource);

  /// Run the complete migration process
  Future<MigrationResult> runMigration() async {
    debugPrint('🚀 Starting database migration...');
    
    final result = MigrationResult();
    
    try {
      // Step 1: Load questions from JSON
      debugPrint('📖 Step 1: Loading questions from JSON...');
      final questionsData = await _loadQuestionsFromJson();
      result.totalQuestions = questionsData.length;
      debugPrint('✅ Loaded ${questionsData.length} questions from JSON');

      // Step 2: Transform and validate questions
      debugPrint('🔄 Step 2: Transforming and validating questions...');
      final questions = _transformQuestions(questionsData);
      debugPrint('✅ Transformed ${questions.length} questions');

      // Step 3: Upload questions to Appwrite
      debugPrint('☁️ Step 3: Uploading questions to Appwrite...');
      await _uploadQuestions(questions, result);
      
      // Step 4: Generate summary
      _generateSummary(result);
      
      return result;
    } catch (e) {
      debugPrint('❌ Migration failed: $e');
      result.errors.add('Migration failed: $e');
      return result;
    }
  }

  /// Load questions from JSON file
  Future<List<Map<String, dynamic>>> _loadQuestionsFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/interview_questions.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      
      final allQuestions = <Map<String, dynamic>>[];
      
      // Extract questions from all categories
      final categories = jsonData['categories'] as List<dynamic>;
      for (final category in categories) {
        final questions = category['questions'] as List<dynamic>;
        for (final question in questions) {
          allQuestions.add(question as Map<String, dynamic>);
        }
      }
      
      return allQuestions;
    } catch (e) {
      debugPrint('❌ Error loading JSON: $e');
      throw Exception('Failed to load questions from JSON: $e');
    }
  }

  /// Transform JSON questions to InterviewQuestion entities
  List<InterviewQuestion> _transformQuestions(List<Map<String, dynamic>> questionsData) {
    final questions = <InterviewQuestion>[];
    
    for (final data in questionsData) {
      try {
        // Map difficulty to experienceLevel if not present
        final experienceLevel = data['experienceLevel'] as String? ?? 
            _mapDifficultyToExperienceLevel(data['difficulty'] as String);
        
        final question = InterviewQuestion(
          id: data['id'] as String,
          question: data['question'] as String,
          category: data['category'] as String,
          difficulty: data['difficulty'] as String,
          evaluationCriteria: List<String>.from(data['evaluationCriteria'] as List),
          roleSpecific: data['roleSpecific'] as String?,
          experienceLevel: experienceLevel,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        );
        
        questions.add(question);
      } catch (e) {
        debugPrint('⚠️ Error transforming question ${data['id']}: $e');
      }
    }
    
    return questions;
  }

  /// Map difficulty to experience level
  String _mapDifficultyToExperienceLevel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'intern';
      case 'intermediate':
        return 'associate';
      case 'advanced':
        return 'senior';
      default:
        return 'associate'; // Default fallback
    }
  }

  /// Upload questions to Appwrite in batches
  Future<void> _uploadQuestions(
    List<InterviewQuestion> questions,
    MigrationResult result,
  ) async {
    const batchSize = 10; // Upload 10 questions at a time
    
    for (var i = 0; i < questions.length; i += batchSize) {
      final batch = questions.skip(i).take(batchSize).toList();
      
      debugPrint('📤 Uploading batch ${(i ~/ batchSize) + 1} (${batch.length} questions)...');
      
      for (final question in batch) {
        try {
          await _datasource.createQuestion(question);
          result.successCount++;
          debugPrint('  ✅ ${question.id}: ${question.question.substring(0, 50)}...');
        } catch (e) {
          result.failureCount++;
          final error = 'Failed to upload ${question.id}: $e';
          result.errors.add(error);
          debugPrint('  ❌ $error');
        }
      }
      
      // Small delay between batches to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Generate migration summary
  void _generateSummary(MigrationResult result) {
    debugPrint('\n${'=' * 60}');
    debugPrint('📊 MIGRATION SUMMARY');
    debugPrint('=' * 60);
    debugPrint('Total Questions: ${result.totalQuestions}');
    debugPrint('Successfully Uploaded: ${result.successCount}');
    debugPrint('Failed: ${result.failureCount}');
    debugPrint('Success Rate: ${result.successRate.toStringAsFixed(2)}%');
    
    if (result.errors.isNotEmpty) {
      debugPrint('\n⚠️ ERRORS (${result.errors.length}):');
      for (var i = 0; i < result.errors.length && i < 10; i++) {
        debugPrint('  ${i + 1}. ${result.errors[i]}');
      }
      if (result.errors.length > 10) {
        debugPrint('  ... and ${result.errors.length - 10} more errors');
      }
    }
    
    debugPrint('=' * 60 + '\n');
  }

  /// Check if migration is needed
  Future<bool> isMigrationNeeded() async {
    try {
      final hasQuestions = await _datasource.hasQuestions();
      if (!hasQuestions) {
        debugPrint('ℹ️ No questions in database - migration needed');
        return true;
      }
      
      final stats = await _datasource.getQuestionStats();
      final questionCount = stats['totalQuestions'] as int;
      
      debugPrint('ℹ️ Database has $questionCount questions');
      
      // If less than 50 questions, migration might be needed
      if (questionCount < 50) {
        debugPrint('⚠️ Question count is low - migration recommended');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('⚠️ Error checking migration status: $e');
      return true; // Assume migration is needed if check fails
    }
  }

  /// Delete all existing questions (use with caution!)
  Future<void> clearAllQuestions() async {
    debugPrint('🗑️ WARNING: Clearing all questions from database...');
    
    try {
      final questions = await _datasource.getQuestions(limit: 1000);
      
      for (final question in questions) {
        try {
          await _datasource.deleteQuestion(question.id);
          debugPrint('  ✅ Deleted: ${question.id}');
        } catch (e) {
          debugPrint('  ❌ Failed to delete ${question.id}: $e');
        }
      }
      
      debugPrint('✅ Cleared ${questions.length} questions');
    } catch (e) {
      debugPrint('❌ Error clearing questions: $e');
      throw Exception('Failed to clear questions: $e');
    }
  }
}

/// Migration result data class
class MigrationResult {
  int totalQuestions = 0;
  int successCount = 0;
  int failureCount = 0;
  List<String> errors = [];

  double get successRate => 
      totalQuestions > 0 ? (successCount / totalQuestions) * 100 : 0;

  bool get isSuccessful => failureCount == 0 && successCount > 0;
}

/// Main function to run migration
Future<void> main() async {
  debugPrint('🎯 InterviewPro Database Migration Tool');
  debugPrint('=' * 60);
  
  // Initialize dependencies
  await initializeDependencies();
  
  // Create migration script
  final datasource = sl<InterviewQuestionRemoteDatasource>();
  final migration = DatabaseMigrationScript(datasource);
  
  // Check if migration is needed
  final isNeeded = await migration.isMigrationNeeded();
  
  if (!isNeeded) {
    debugPrint('ℹ️ Migration not needed - database already has sufficient questions');
    debugPrint('💡 To force migration, uncomment the clearAllQuestions() call');
    return;
  }
  
  // Optional: Clear existing questions (UNCOMMENT WITH CAUTION!)
  // await migration.clearAllQuestions();
  
  // Run migration
  final result = await migration.runMigration();
  
  // Report results
  if (result.isSuccessful) {
    debugPrint('✅ Migration completed successfully!');
  } else {
    debugPrint('⚠️ Migration completed with errors');
  }
}
