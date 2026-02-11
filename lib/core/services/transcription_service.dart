import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for transcribing audio files using Gemini 1.5 Flash
class TranscriptionService {
  final String _apiKey;
  GenerativeModel? _flashModel;
  GenerativeModel? _fallbackModel;

  /// Global registry of active transcription tasks to persist across screens
  static final Map<String, Future<String>> _activeTasks = {};

  /// Stream for notifying listeners about transcription progress/completion
  static final StreamController<Map<String, String>> _statusController =
      StreamController<Map<String, String>>.broadcast();

  TranscriptionService()
    : _apiKey = dotenv.get('GEMINI_API_KEY', fallback: '') {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      debugPrint('⚠️ Gemini API Key not found or invalid in .env');
    } else {
      // Pre-initialize models to save time
      _flashModel = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: _apiKey,
      );
      _fallbackModel = GenerativeModel(
        model: 'gemini-2.0-flash-lite',
        apiKey: _apiKey,
      );
    }
  }

  /// Start transcription in background and track it globally
  void queueTranscription(String interviewId, String filePath) {
    if (_activeTasks.containsKey(interviewId)) return;

    debugPrint('🚀 Proactive STT started for: $interviewId');
    final future = transcribeFile(filePath);
    _activeTasks[interviewId] = future;

    future
        .then((transcript) {
          _statusController.add({interviewId: transcript});
        })
        .catchError((e) {
          debugPrint('❌ Proactive STT failed for $interviewId: $e');
        });
  }

  /// Get the existing task future if it exists
  Future<String>? getActiveTask(String interviewId) =>
      _activeTasks[interviewId];

  /// Stream of completed transcriptions
  Stream<Map<String, String>> get statusStream => _statusController.stream;

  Future<String> transcribeFile(String filePath) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return 'Error: Gemini API Key not found. Please set GEMINI_API_KEY in .env';
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('❌ Transcription error: File not found at $filePath');
        return 'Error: Audio file not found.';
      }

      final bytes = await file.readAsBytes();
      debugPrint('🎙️ Transcribing: ${file.path.split('/').last}');
      debugPrint('📂 Size: ${(bytes.length / 1024).toStringAsFixed(1)} KB');

      final content = [
        Content.multi([
          DataPart('audio/mp4', bytes),
          TextPart(
            'Transcribe this interview audio verbatim. \n'
            'RULES:\n'
            '1. Start directly with labels. NO preamble or intro text.\n'
            '2. Use "Interviewer:" and "Candidate:" labels precisely.\n'
            '3. NO markdown bolding (e.g., NO **Interviewer:**).\n'
            '4. Return ONLY the plain text dialogue.\n'
            'Format:\n'
            'Interviewer: [Text]\n'
            'Candidate: [Text]',
          ),
        ]),
      ];

      // Try with Flash Lite primary (Available, High-speed, 2.0)
      try {
        final response =
            await (_fallbackModel ??
                    GenerativeModel(
                      model: 'gemini-2.0-flash-lite',
                      apiKey: _apiKey,
                    ))
                .generateContent(content);

        if (response.text != null && response.text!.isNotEmpty) {
          debugPrint('✅ STT Success (Lite Primary)');
          return response.text!.trim();
        }
      } catch (e) {
        debugPrint('⚠️ Lite Primary STT attempt failed: $e');

        // Fallback to Flash Latest if permissible, otherwise Pro
        try {
          final fallbackResponse =
              await (_flashModel ??
                      GenerativeModel(
                        model: 'gemini-flash-latest',
                        apiKey: _apiKey,
                      ))
                  .generateContent(content);

          if (fallbackResponse.text != null &&
              fallbackResponse.text!.isNotEmpty) {
            debugPrint('✅ STT Success (Secondary)');
            return fallbackResponse.text!.trim();
          }
        } catch (e2) {
          debugPrint('❌ All STT attempts failed: $e2');
          rethrow;
        }
      }

      return 'Transcription failed: No text generated.';
    } catch (e) {
      debugPrint('❌ STT Error: $e');
      if (e.toString().contains('429')) {
        return 'AI Speed Limit reached. Please wait 30 seconds and try again.';
      }
      return 'AI Transcription failed: ${e.toString().split('\n').first}';
    }
  }
}
