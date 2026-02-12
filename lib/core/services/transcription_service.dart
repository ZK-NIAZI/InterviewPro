import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

/// Service for transcribing audio files using a Groq-centered pipeline (Whisper + Llama 3)
/// with a resilient fallback to Gemini for high-fidelity audio processing.
class TranscriptionService {
  final String _apiKey;
  final String _groqApiKey;
  GenerativeModel? _flashModel;
  GenerativeModel? _fallbackModel;

  /// Global registry of active transcription tasks
  static final Map<String, Future<String>> _activeTasks = {};

  /// Global registry of pending tasks waiting for connectivity
  static final Map<String, String> _pendingTasks = {};

  /// Stream for notifying listeners about transcription progress/completion
  static final StreamController<Map<String, String>> _statusController =
      StreamController<Map<String, String>>.broadcast();

  TranscriptionService()
    : _apiKey = dotenv.get('GEMINI_API_KEY', fallback: ''),
      _groqApiKey = dotenv.get('GROQ_API_KEY', fallback: '') {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      debugPrint('⚠️ Gemini API Key not found or invalid in .env');
    }

    if (_groqApiKey.isEmpty) {
      debugPrint('⚠️ Groq API Key not found in .env (Hybrid Mode disabled)');
    } else {
      debugPrint('🚀 Groq Hybrid Mode initialized and ready.');
    }

    if (_apiKey.isNotEmpty) {
      _flashModel = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: _apiKey,
      );
      _fallbackModel = GenerativeModel(
        model: 'gemini-2.0-flash-lite',
        apiKey: _apiKey,
      );

      // Initialize connectivity listener to resume pending tasks
      Connectivity().onConnectivityChanged.listen((results) {
        // results is a List<ConnectivityResult> in newer versions
        final isConnected = results.any((r) => r != ConnectivityResult.none);
        if (isConnected && _pendingTasks.isNotEmpty) {
          debugPrint(
            '🌐 Connection restored. Resuming ${_pendingTasks.length} pending STT tasks...',
          );
          _processPendingTasks();
        }
      });
    }
  }

  /// Process all tasks that were queued while offline
  void _processPendingTasks() {
    final tasks = Map<String, String>.from(_pendingTasks);
    _pendingTasks.clear();
    tasks.forEach((id, path) {
      queueTranscription(id, path);
    });
  }

  /// Check if the device is currently online
  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  /// Start transcription in background and track it globally
  void queueTranscription(String interviewId, String filePath) async {
    if (_activeTasks.containsKey(interviewId)) return;

    // Check connectivity before starting
    if (!await _isOnline()) {
      debugPrint(
        '📶 Device offline. Queuing STT for $interviewId until connection is restored.',
      );
      _pendingTasks[interviewId] = filePath;
      return;
    }

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
            'Identify and separate multiple speakers. \n'
            'Label the primary candidate as "Candidate". \n'
            'Label different interviewers as "Interviewer 1", "Interviewer 2", etc., based on their voice and context. \n'
            'RULES:\n'
            '1. Return ONLY a valid JSON array of objects. NO preamble or intro text.\n'
            '2. Each object must have "speaker", "text", and "time" (in M:SS format) keys.\n'
            '3. Use dialogue context to infer which interviewer is speaking if possible.\n'
            '4. NO markdown bolding in the text content.\n'
            'Format Example:\n'
            '[\n'
            '  {"speaker": "Interviewer 1", "time": "0:00", "text": "Hello..."}, \n'
            '  {"speaker": "Candidate", "time": "0:05", "text": "Hi..."}\n'
            ']',
          ),
        ]),
      ];

      // Use the Groq-centered pipeline (Whisper STT + Llama Diarization)
      if (_groqApiKey.isNotEmpty && _groqApiKey.length > 10) {
        return await _transcribeWithGroqPipeline(filePath);
      } else {
        final rawResult = await _generateWithRetry(content);
        return _validateAndCleanJson(rawResult);
      }
    } catch (e) {
      debugPrint('❌ STT Error: $e');
      if (e.toString().contains('429')) {
        return 'AI Speed Limit reached. Please wait 30 seconds and try again.';
      }
      return 'AI Transcription failed: ${e.toString().split('\n').first}';
    }
  }

  /// Validates that the output is valid JSON and strips any AI markdown wrappers
  String _validateAndCleanJson(String rawOutput) {
    try {
      // 1. Strip potential markdown blocks: ```json [...] ```
      String cleaned = rawOutput.trim();
      if (cleaned.startsWith('```')) {
        final lines = cleaned.split('\n');
        // Remove first line if it starts with ``` (e.g. ```json)
        if (lines.isNotEmpty && lines.first.startsWith('```')) {
          lines.removeAt(0);
        }
        // Remove last line if it starts with ```
        if (lines.isNotEmpty && lines.last.startsWith('```')) {
          lines.removeLast();
        }
        cleaned = lines.join('\n').trim();
      }

      // 2. Validate it's actually valid JSON to catch AI hallucinations
      jsonDecode(cleaned);

      return cleaned;
    } catch (e) {
      debugPrint('⚠️ JSON Validation failed, returning raw string: $e');
      return rawOutput;
    }
  }

  /// Private helper to handle generative AI calls with exponential backoff
  Future<String> _generateWithRetry(
    List<Content> content, {
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        // Primary Attempt with Flash Lite (Optimized for speed/cost)
        final response =
            await (_fallbackModel ??
                    GenerativeModel(
                      model: 'gemini-2.0-flash-lite',
                      apiKey: _apiKey,
                    ))
                .generateContent(content);

        if (response.text != null && response.text!.isNotEmpty) {
          debugPrint('✅ STT Success (Attempt ${attempts + 1})');
          return response.text!.trim();
        }

        throw Exception('Empty response from AI');
      } catch (e) {
        attempts++;
        final errorStr = e.toString();

        // Handle transient errors or rate limits
        bool isTransient =
            errorStr.contains('429') ||
            errorStr.contains('500') ||
            errorStr.contains('503') ||
            errorStr.contains('deadline') ||
            errorStr.contains('SocketException');

        if (isTransient && attempts < maxRetries) {
          final delaySeconds = attempts * attempts * 2; // 2s, 8s, 18s...
          debugPrint(
            '⚠️ STT Attempt $attempts failed (Transient). Retrying in ${delaySeconds}s... ($e)',
          );
          await Future.delayed(Duration(seconds: delaySeconds));
          continue;
        }

        // If not transient or we've reached max retries, try the secondary fallback model
        if (attempts >= maxRetries) {
          debugPrint(
            '🔄 Max retries reached with Flash Lite. Trying Flash Latest as last resort...',
          );
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
              debugPrint('✅ STT Success (Secondary Fallback)');
              return fallbackResponse.text!.trim();
            }
          } catch (e2) {
            debugPrint('❌ Final STT fallback also failed: $e2');
            rethrow;
          }
        }

        rethrow;
      }
    }
    return 'Transcription failed after multiple attempts.';
  }

  /// High-speed Raw STT via Groq Whisper (Large V3 Turbo) with Resilience
  Future<String> _transcribeWithGroq(String filePath) async {
    return _retry(() async {
      final url = Uri.parse(
        'https://api.groq.com/openai/v1/audio/transcriptions',
      );
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $_groqApiKey'
        ..fields['model'] = 'whisper-large-v3-turbo'
        ..fields['response_format'] = 'verbose_json'
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final segments = data['segments'] as List?;

        if (segments != null && segments.isNotEmpty) {
          return segments
              .map((s) {
                final start = s['start']?.toStringAsFixed(2) ?? '0.00';
                final end = s['end']?.toStringAsFixed(2) ?? '0.00';
                final text = s['text']?.trim() ?? '';
                return '[$start - $end]: $text';
              })
              .join('\n');
        }

        return data['text'] ?? '';
      } else {
        throw Exception(
          'Groq Whisper Error: ${response.statusCode} - ${response.body}',
        );
      }
    }, label: 'Groq Whisper');
  }

  /// Generic Groq Chat Completion helper (Llama 3.3 70B) with Resilience
  Future<String> _callGroqChat(String prompt) async {
    return _retry(() async {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $_groqApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'llama-3.3-70b-versatile',
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a high-integrity transcription editor. Your SOLE task is to assign speaker labels to provided audio segments. \n\n'
                      'CRITICAL LINGUISTIC RULES:\n'
                      '1. SEMANTIC CONTINUITY: If a segment starts with a lowercase letter or follows a segment without ending punctuation (., ?, !), it MUST be assigned to the same speaker unless there is a huge timestamp gap.\n'
                      '2. SEGMENT SPLITTING: If a single segment contains a speaker shift (e.g., a question followed by an answer), you MUST split it into multiple JSON objects. \n'
                      '3. NO WORD EDITS: NEVER change, add, or remove a single word from the "text" field of the segments.\n'
                      '4. SPEAKER ROLES: Candidates provide technical explanations; Interviewers ask questions.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.1,
              'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? '';
      } else {
        throw Exception(
          'Groq Chat Error: ${response.statusCode} - ${response.body}',
        );
      }
    }, label: 'Groq Llama');
  }

  /// Generic retry helper with exponential backoff
  Future<T> _retry<T>(
    Future<T> Function() action, {
    int maxRetries = 3,
    required String label,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await action();
      } catch (e) {
        attempts++;
        final errorStr = e.toString();

        bool isTransient =
            errorStr.contains('429') ||
            errorStr.contains('500') ||
            errorStr.contains('503') ||
            errorStr.contains('deadline') ||
            errorStr.contains('SocketException') ||
            errorStr.contains('TimeoutException');

        if (isTransient && attempts < maxRetries) {
          final delaySeconds = attempts * attempts * 2; // 2s, 8s, 18s...
          debugPrint(
            '⚠️ $label Attempt $attempts failed. Retrying in ${delaySeconds}s... ($e)',
          );
          await Future.delayed(Duration(seconds: delaySeconds));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('$label failed after $maxRetries attempts');
  }

  /// Converts raw text to structured JSON turns using Groq Llama 3.3
  Future<String> _diarizeWithGroq(String rawText) async {
    final prompt =
        'Context: Technical interview segments with [Start - End] timestamps. \n'
        'Task: Convert these segments into a clean JSON transcript.\n\n'
        'INTEGRITY CONSTRAINTS:\n'
        '- Preserve 100% of the words. \n'
        '- HANDLE MERGED SEGMENTS: If a segment contains a speaker shift (e.g., "Interviewer asks? Candidate answers."), split it into two objects.\n'
        '- SENTENCE CONTINUITY: If a segment starts with "...widget" and follows "Stateful", keep the same speaker.\n'
        '- Use "Candidate", "Interviewer 1", "Interviewer 2" based on context and audio cues in text.\n\n'
        'JSON FORMAT:\n'
        '{"transcript": [{"speaker": "Label", "time": "M:SS", "text": "Exact text"}]}\n\n'
        'SEGMENTS TO PROCESS: \n$rawText';

    final result = await _callGroqChat(prompt);

    try {
      final decoded = jsonDecode(result);
      if (decoded is Map && decoded.containsKey('transcript')) {
        return jsonEncode(decoded['transcript']);
      }
      return result;
    } catch (e) {
      debugPrint('⚠️ Groq JSON unwrapping failed, returning raw result: $e');
      return result;
    }
  }

  /// Total Groq Orchestrator with Failover to Gemini Audio
  Future<String> _transcribeWithGroqPipeline(String filePath) async {
    try {
      // 1. Raw Transcription (Groq Whisper)
      final rawText = await _transcribeWithGroq(filePath);

      // 2. Diarization (Groq Llama 3)
      final structuredJson = await _diarizeWithGroq(rawText);

      return _validateAndCleanJson(structuredJson);
    } catch (e) {
      debugPrint(
        '⚠️ Groq Pipeline failed: $e. Falling back to Gemini Audio...',
      );
      // Final Fallback: Revert to legacy audio-processing mode with high-quality prompt
      final bytes = await File(filePath).readAsBytes();
      final content = [
        Content.multi([
          DataPart('audio/mp4', bytes),
          TextPart(
            'Transcribe this interview audio verbatim. \n'
            'Identify and separate multiple speakers. \n'
            'Label the primary candidate as "Candidate". \n'
            'Label different interviewers as "Interviewer 1", "Interviewer 2", etc.\n'
            'RULES:\n'
            '1. Return ONLY a valid JSON array of objects.\n'
            '2. Each object must have "speaker", "text", and "time" (in M:SS format) keys.\n'
            'Format Example: [{"speaker": "Interviewer 1", "time": "0:00", "text": "..."}]',
          ),
        ]),
      ];
      final backupResult = await _generateWithRetry(content);
      return _validateAndCleanJson(backupResult);
    }
  }
}
