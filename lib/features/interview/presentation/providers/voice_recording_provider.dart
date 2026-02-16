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
  String? _activeInterviewId;

  // Playback state
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _completeSubscription;
  StreamSubscription? _recordingStateSubscription;

  VoiceRecordingProvider(this._recordingService) {
    _initPlaybackListeners();
    _initRecordingListener();
  }

  void _initRecordingListener() {
    _recordingStateSubscription = _recordingService.onRecordingStateChanged
        .listen((isRecording) {
          _isRecording = isRecording;
          if (isRecording) {
            _startTimer();
          } else {
            _stopTimer();
          }
          notifyListeners();
        });
  }

  // Getters
  bool get isRecording => _isRecording;
  int get recordingDurationSeconds => _recordingDurationSeconds;
  String? get activeInterviewId => _activeInterviewId;

  // Playback Getters
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  /// Start recording for an interview
  Future<void> start({
    required String interviewId,
    required String candidateName,
  }) async {
    try {
      // Logic is handled by the service and listener now
      await _recordingService.startRecording(
        interviewId: interviewId,
        candidateName: candidateName,
      );

      _activeInterviewId = interviewId;
      _recordingDurationSeconds = 0;
      // Timer start is handled by listener
    } catch (e) {
      _activeInterviewId = null;
      _recordingDurationSeconds = 0;
      // Error state handling
      debugPrint('❌ Error in VoiceRecordingProvider.start: $e');
      rethrow;
    }
  }

  /// Stop current interview-wide recording
  Future<String?> stop() async {
    try {
      // Timer stop is handled by listener
      final path = await _recordingService.stopRecording();
      // State update handled by listener
      return path;
    } catch (e) {
      debugPrint('❌ Error in VoiceRecordingProvider.stop: $e');
      // State update handled by listener (service sends false on error)
      rethrow;
    }
  }

  /// Cancel current recording (discard)
  Future<void> cancel() async {
    try {
      await _recordingService.stopRecording();

      _activeInterviewId = null;
      _recordingDurationSeconds = 0;
      // Listener will handle isRecording = false
    } catch (e) {
      debugPrint('❌ Error in VoiceRecordingProvider.cancel: $e');
    }
  }

  /// Check if an interview has a recording (Note: Legacy helper, might need update)
  bool hasRecording(String id) {
    return _recordingService.getMetadata(id) != null;
  }

  /// Get recording path
  String? getRecordingPath(String id) {
    return _recordingService.getMetadata(id)?['path'] as String?;
  }

  /// Get recording duration
  int? getRecordingDuration(String id) {
    return _recordingService.getMetadata(id)?['duration'] as int?;
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

  final ValueNotifier<int> recordingDurationNotifier = ValueNotifier<int>(0);

  void _startTimer() {
    _timer?.cancel();
    recordingDurationNotifier.value = _recordingDurationSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDurationSeconds++;
      recordingDurationNotifier.value = _recordingDurationSeconds;
      // ⚡ Performance Fix: Removed notifyListeners() to prevent full-page rebuilds every second.
      // UI should now listen to recordingDurationNotifier specifically.
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    _recordingStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _completeSubscription?.cancel();
    super.dispose();
  }
}
