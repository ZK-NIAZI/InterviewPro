import 'dart:async';
import 'package:flutter/material.dart';
import 'package:interview_pro_app/core/services/voice_recording_service.dart';

/// Provider for managing voice recording state and UI updates
class VoiceRecordingProvider extends ChangeNotifier {
  final VoiceRecordingService _recordingService;

  bool _isRecording = false;
  int _recordingDurationSeconds = 0;
  Timer? _timer;
  String? _activeQuestionId;

  VoiceRecordingProvider(this._recordingService);

  // Getters
  bool get isRecording => _isRecording;
  int get recordingDurationSeconds => _recordingDurationSeconds;
  String? get activeQuestionId => _activeQuestionId;

  /// Start recording for a question
  Future<void> start({required String questionId}) async {
    try {
      await _recordingService.startRecording(questionId);

      _isRecording = true;
      _activeQuestionId = questionId;
      _recordingDurationSeconds = 0;

      _startTimer();
      notifyListeners();
    } catch (e) {
      _isRecording = false;
      _activeQuestionId = null;
      _recordingDurationSeconds = 0;
      _stopTimer();
      notifyListeners();

      debugPrint('❌ Error in VoiceRecordingProvider.start: $e');
      rethrow;
    }
  }

  /// Stop current recording
  Future<String?> stop() async {
    try {
      _stopTimer();
      final path = await _recordingService.stopRecording();

      if (path != null && _activeQuestionId != null) {
        await _recordingService.saveMetadata(
          questionId: _activeQuestionId!,
          path: path,
          durationSeconds: _recordingDurationSeconds,
        );
      }

      _isRecording = false;
      notifyListeners();
      return path;
    } catch (e) {
      debugPrint('❌ Error in VoiceRecordingProvider.stop: $e');
      _isRecording = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Cancel current recording (discard)
  Future<void> cancel() async {
    try {
      _stopTimer();
      await _recordingService.stopRecording();

      if (_activeQuestionId != null) {
        await _recordingService.deleteRecording(_activeQuestionId!);
      }

      _isRecording = false;
      _activeQuestionId = null;
      _recordingDurationSeconds = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error in VoiceRecordingProvider.cancel: $e');
      _isRecording = false;
      notifyListeners();
    }
  }

  /// Check if a question has a recording
  bool hasRecording(String questionId) {
    return _recordingService.getMetadata(questionId) != null;
  }

  /// Get recording path for a question
  String? getRecordingPath(String questionId) {
    return _recordingService.getMetadata(questionId)?['path'] as String?;
  }

  /// Get recording duration for a question
  int? getRecordingDuration(String questionId) {
    return _recordingService.getMetadata(questionId)?['duration'] as int?;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDurationSeconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
