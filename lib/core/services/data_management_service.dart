import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../shared/domain/entities/entities.dart';
import '../../shared/domain/repositories/interview_repository.dart';
import '../../core/services/crash_reporting_service.dart';

/// Service for managing data export and import operations
class DataManagementService {
  final InterviewRepository _repository;

  DataManagementService(this._repository);

  /// Export all data (Interviews + Responses) to a JSON file
  Future<bool> exportData() async {
    try {
      final interviews = await _repository.getAllInterviews();
      final Map<String, dynamic> exportData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'interviews': [],
        'responses': {},
      };

      for (final interview in interviews) {
        // Add interview
        (exportData['interviews'] as List).add(interview.toJson());

        // Add associated responses
        final responses = await _repository.getQuestionResponses(interview.id);
        (exportData['responses'] as Map<String, dynamic>)[interview.id] =
            responses.map((r) => r.toJson()).toList();
      }

      // Create file
      final directory = await getApplicationDocumentsDirectory();
      final dateStr = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final fileName = 'interview_pro_backup_$dateStr.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonEncode(exportData));

      // Share file
      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Interview Pro Backup');

      return true;
    } catch (e, stack) {
      debugPrint('❌ Export failed: $e');
      CrashReportingService().recordError(
        e,
        stack,
        reason: 'Data Export Failed',
      );
      return false;
    }
  }

  /// Import data from a JSON file
  Future<bool> importData() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return false;

      final file = File(result.files.single.path!);
      final String content = await file.readAsString();
      final Map<String, dynamic> importData = jsonDecode(content);

      // Validate version
      final int version = importData['version'] ?? 0;
      if (version != 1) {
        throw Exception('Unsupported backup version: $version');
      }

      // Process Interviews
      final List<dynamic> interviewsJson = importData['interviews'] ?? [];
      int importedCount = 0;

      for (final json in interviewsJson) {
        try {
          final interview = Interview.fromJson(json);
          // Only import if it doesn't exist or is newer
          final existing = await _repository.getInterviewById(interview.id);

          if (existing == null ||
              interview.lastModified.isAfter(existing.lastModified)) {
            await _repository.saveInterview(interview);
            importedCount++;

            // Import associated responses
            if (importData['responses'] != null &&
                importData['responses'][interview.id] != null) {
              final responsesList =
                  importData['responses'][interview.id] as List;
              for (final rJson in responsesList) {
                final response = QuestionResponse.fromJson(rJson);
                await _repository.saveQuestionResponse(interview.id, response);
              }
            }
          }
        } catch (e) {
          debugPrint('⚠️ Skipping invalid interview in import: $e');
        }
      }

      debugPrint('✅ Imported $importedCount interviews');
      return true;
    } catch (e, stack) {
      debugPrint('❌ Import failed: $e');
      CrashReportingService().recordError(
        e,
        stack,
        reason: 'Data Import Failed',
      );
      return false;
    }
  }
}
