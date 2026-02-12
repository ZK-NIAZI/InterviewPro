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

  String? _lastRecordingPath; // Added to persist path across errors

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

    _lastRecordingPath = null; // ⚡ FIX: Reset path at start of new recording

    final directory = await getApplicationDocumentsDirectory();
    final sanitizedCandidate = candidateName.replaceAll(' ', '_');
    // ⚡ FIX: Consolidated prefix (removed redundant 'interview_')
    final fileName =
        '${interviewId}_${sanitizedCandidate}_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final filePath = '${directory.path}/$fileName';
    _lastRecordingPath = filePath;

    // Optimized for STT performance: 64kbps/24kHz is plenty for clear speech
    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 64000,
      sampleRate: 24000,
    );

    try {
      debugPrint('🎙️ Starting audio recorder...');
      await _recorder.start(config, path: filePath);
      debugPrint('🎙️ Audio recorder started: $filePath');
    } catch (e) {
      debugPrint('❌ Critical Error: Failed to start recorder: $e');
      rethrow;
    }
  }

  /// Stop current recording and return the path
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      debugPrint('🛑 Stopped recording: $path');

      // Check file size if path exists
      final finalPath = path ?? _lastRecordingPath;
      if (finalPath != null) {
        final file = File(finalPath);
        if (await file.exists()) {
          final size = await file.length();
          debugPrint('📂 Final recording size: ${size / 1024} KB');
        }
      }

      return finalPath;
    } catch (e) {
      debugPrint('⚠️ Error in stopRecording: $e');
      return _lastRecordingPath;
    }
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

  /// Delete a specific file by its path
  Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Manually deleted file: $path');
      }
    } catch (e) {
      debugPrint('⚠️ Error deleting file at $path: $e');
    }
  }

  /// Delete all audio files for an interview EXCEPT the active one
  Future<void> cleanupRedundantRecordings(
    String interviewId,
    String activePath,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      int deletedCount = 0;

      for (final file in files) {
        if (file is File &&
            file.path.contains(interviewId) && // Match ID directly
            file.path.endsWith('.m4a') &&
            file.path != activePath) {
          await file.delete();
          deletedCount++;
        }
      }

      if (deletedCount > 0) {
        debugPrint(
          '🧹 Cleaned up $deletedCount redundant recordings for interview $interviewId',
        );
      }
    } catch (e) {
      debugPrint('⚠️ Error during redundant cleanup: $e');
    }
  }

  /// Remove all audio files that don't correspond to any valid interview IDs
  Future<void> cleanupOrphanedRecordings(List<String> validInterviewIds) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      int deletedCount = 0;

      for (final file in files) {
        if (file is File &&
            file.path.contains('interview_') &&
            file.path.endsWith('.m4a')) {
          // Check if this file belongs to any valid interview
          bool isOrphaned = true;
          for (final id in validInterviewIds) {
            if (file.path.contains(id)) {
              // Match ID directly
              isOrphaned = false;
              break;
            }
          }

          if (isOrphaned) {
            await file.delete();
            deletedCount++;
          }
        }
      }

      if (deletedCount > 0) {
        debugPrint('🧹 Cleaned up $deletedCount orphaned audio files');
      }
    } catch (e) {
      debugPrint('⚠️ Error during orphaned cleanup: $e');
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
