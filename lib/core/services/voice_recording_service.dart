import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

/// Service for handling audio recording logic and persistence metadata
class VoiceRecordingService {
  final Box _box;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  VoiceRecordingService(this._box) {
    _initAudioContext();
  }

  void _initAudioContext() {
    try {
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: const AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: [
              AVAudioSessionOptions.defaultToSpeaker,
              AVAudioSessionOptions.mixWithOthers,
            ],
          ),
        ),
      );
      debugPrint('🎵 AudioContext initialized successfully');
    } catch (e) {
      debugPrint('⚠️ Error initializing AudioContext: $e');
    }
  }

  /// Check and request microphone permission
  Future<bool> checkPermission() async {
    try {
      final status = await Permission.microphone.status;
      if (status.isGranted) return true;

      final result = await Permission.microphone.request();
      return result.isGranted;
    } on Exception catch (e) {
      if (e.toString().contains('MissingPluginException')) {
        debugPrint(
          '⚠️ Permission handler plugin not yet registered. Rebuilding recommended.',
        );
      }
      debugPrint('❌ Error checking permissions: $e');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error checking permissions: $e');
      return false;
    }
  }

  /// Start recording audio for an interview session
  Future<void> startRecording({
    required String interviewId,
    required String candidateName,
  }) async {
    if (!await checkPermission()) {
      throw Exception('Microphone permission not granted');
    }

    if (await _recorder.isRecording()) {
      await stopRecording();
    }

    await stopPlayback();

    final directory = await getApplicationDocumentsDirectory();
    final sanitizedCandidate = candidateName.replaceAll(' ', '_');
    final fileName =
        'interview_${interviewId}_${sanitizedCandidate}_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final filePath = '${directory.path}/$fileName';

    // Explicitly use AAC-LC for better compatibility on emulators
    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    );

    await _recorder.start(config, path: filePath);
    debugPrint('🎙️ Started interview-wide recording: $filePath');
  }

  /// Stop current recording and return the path
  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    debugPrint('🛑 Stopped recording: $path');
    return path;
  }

  /// Pause current recording
  Future<void> pauseRecording() async {
    await _recorder.pause();
    debugPrint('⏸️ Paused recording');
  }

  /// Resume current recording
  Future<void> resumeRecording() async {
    await _recorder.resume();
    debugPrint('▶️ Resumed recording');
  }

  /// Check if currently recording
  Future<bool> isRecording() => _recorder.isRecording();

  // --- Playback Section ---

  /// Play audio from path
  Future<void> play(String path) async {
    // Ensure context is set before every playback (helps if service was already alive during H.Reload)
    _initAudioContext();
    final file = File(path);
    if (!await file.exists()) {
      debugPrint('❌ Playback error: File does not exist at $path');
      return;
    }

    final size = await file.length();
    debugPrint('📂 File size: ${size / 1024} KB');

    if (size < 100) {
      debugPrint(
        '⚠️ Warning: File size is very small, might be silent or corrupted.',
      );
    }

    await _player.stop();
    await _player.setVolume(1.0); // Ensure volume is up
    await _player.play(DeviceFileSource(path));

    // Add duration check
    final duration = await _player.getDuration();
    debugPrint('⏳ Audio duration: $duration');

    debugPrint('▶️ Started playback: $path');
  }

  /// Pause current playback
  Future<void> pausePlayback() async {
    await _player.pause();
    debugPrint('⏸️ Paused playback');
  }

  /// Resume current playback
  Future<void> resumePlayback() async {
    await _player.resume();
    debugPrint('▶️ Resumed playback');
  }

  /// Stop current playback
  Future<void> stopPlayback() async {
    await _player.stop();
    debugPrint('🛑 Stopped playback');
  }

  /// Seek to a specific position
  Future<void> seekPlayback(Duration position) async {
    await _player.seek(position);
  }

  /// Stream of playback position updates
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;

  /// Stream of player state changes
  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;

  /// Stream of playback completion
  Stream<void> get onPlaybackComplete => _player.onPlayerComplete;

  /// Get total duration of the current audio
  Future<Duration?> getDuration() => _player.getDuration();

  /// Save recording metadata to Hive
  Future<void> saveMetadata({
    required String questionId,
    required String path,
    required int durationSeconds,
  }) async {
    await _box.put(questionId, {
      'path': path,
      'duration': durationSeconds,
      'timestamp': DateTime.now().toIso8601String(),
    });
    debugPrint('💾 Saved metadata for $questionId');
  }

  /// Get recording metadata from Hive
  Map<String, dynamic>? getMetadata(String questionId) {
    final data = _box.get(questionId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Delete recording file and metadata
  Future<void> deleteRecording(String questionId) async {
    final metadata = getMetadata(questionId);
    if (metadata != null) {
      final path = metadata['path'] as String;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Deleted file: $path');
      }
      await _box.delete(questionId);
      debugPrint('🗑️ Deleted metadata for $questionId');
    }
  }

  /// Clear all recordings (e.g., when interview is cancelled)
  Future<void> clearAll() async {
    for (final key in _box.keys) {
      await deleteRecording(key.toString());
    }
  }

  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
