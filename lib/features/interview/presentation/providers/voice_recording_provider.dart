import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:interview_pro_app/core/services/voice_recording_service.dart';

/// Provider for managing voice recording state and UI updates
class VoiceRecordingProvider extends ChangeNotifier {
  final VoiceRecordingService _recordingService;

  bool _isRecording = false;
  int _recordingDurationSeconds = 0;
  Timer? _timer;
  String? _activeQuestionId;

  // Playback state
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _completeSubscription;

  VoiceRecordingProvider(this._recordingService) {
    _initPlaybackListeners();
  }

  // Getters
  bool get isRecording => _isRecording;
  int get recordingDurationSeconds => _recordingDurationSeconds;
  String? get activeQuestionId => _activeQuestionId;

  // Playback Getters
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

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

  // --- Playback Section ---

  /// Start playing a recording
  Future<void> playRecording(String questionId) async {
    final path = getRecordingPath(questionId);
    if (path == null) return;

    try {
      await _recordingService.play(path);
      _totalDuration = (await _recordingService.getDuration()) ?? Duration.zero;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error playing recording: $e');
    }
  }

  /// Pause current playback
  Future<void> pausePlayback() async {
    await _recordingService.pausePlayback();
    _isPlaying = false;
    notifyListeners();
  }

  /// Resume current playback
  Future<void> resumePlayback() async {
    await _recordingService.resumePlayback();
    _isPlaying = true;
    notifyListeners();
  }

  /// Stop current playback
  Future<void> stopPlayback() async {
    await _recordingService.stopPlayback();
    _isPlaying = false;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  /// Seek to a specific position
  Future<void> seekPlayback(Duration position) async {
    await _recordingService.seekPlayback(position);
  }

  void _initPlaybackListeners() {
    _positionSubscription = _recordingService.onPositionChanged.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });

    _playerStateSubscription = _recordingService.onPlayerStateChanged.listen((
      state,
    ) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _completeSubscription = _recordingService.onPlaybackComplete.listen((_) {
      _isPlaying = false;
      _currentPosition = Duration.zero;
      notifyListeners();
    });
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
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _completeSubscription?.cancel();
    super.dispose();
  }
}
