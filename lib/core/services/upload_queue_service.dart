import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'drive_service.dart';
import '../../shared/data/datasources/sync_remote_datasource.dart';

/// Service to handle background uploads with offline resilience
import '../providers/auth_provider.dart';

/// Service to handle background uploads with offline resilience
class UploadQueueService {
  final DriveService _driveService;
  final Box _queueBox;
  final AuthProvider _authProvider;
  final SyncRemoteDatasource _syncRemoteDatasource;

  static const String _boxName = 'uploadQueue';
  static const String _folderName = 'InterviewPro_Recordings';
  String? _cachedFolderId;
  bool _isProcessRunning = false;

  UploadQueueService(
    this._driveService,
    this._authProvider,
    this._syncRemoteDatasource,
  ) : _queueBox = Hive.box(_boxName) {
    _initConnectivityListener();
  }

  /// Initialize Hive box for the queue
  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  /// Listen for connectivity changes to retry uploads
  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((results) {
      // connectivity_plus 6.0 returns a List<ConnectivityResult>
      if (results.any((result) => result != ConnectivityResult.none)) {
        debugPrint('🌐 Network restored, processing upload queue...');
        processQueue();
      }
    });
  }

  /// Add a file to the upload queue and trigger processing
  Future<void> addToQueue({
    required String interviewId,
    required String filePath,
    required String candidateName,
    String candidateEmail =
        'unknown@candidate.com', // Placeholder until we have real email collection
    String? candidatePhone,
  }) async {
    final task = {
      'interviewId': interviewId,
      'filePath': filePath,
      'timestamp': DateTime.now().toIso8601String(),
      'retryCount': 0,
      // Add sidecar data to task to avoid dependence on local repository during background processing
      'candidateName': candidateName,
      'candidateEmail': candidateEmail,
      'candidatePhone': candidatePhone,
      'createdTime': DateTime.now().toIso8601String(),
    };

    await _queueBox.add(task);
    debugPrint('📥 Added upload task for $interviewId to queue');

    // Try to process immediately
    processQueue();
  }

  /// Process pending uploads in the queue
  Future<void> processQueue() async {
    if (_isProcessRunning) return;
    if (_queueBox.isEmpty) return;

    // Check connectivity first
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.every((result) => result == ConnectivityResult.none)) {
      debugPrint('⚠️ No internet connection. Pausing upload queue.');
      return;
    }

    _isProcessRunning = true;

    try {
      // Ensure we have a valid client before processing
      final client = await _authProvider.getAuthenticatedClient();
      if (client != null) {
        _driveService.updateClient(client);
      } else {
        debugPrint('⚠️ User not signed in. pausing upload queue processing.');
        return;
      }

      // Ensure we have the target folder ID
      if (_cachedFolderId == null) {
        _cachedFolderId = await _driveService.getOrCreateFolder(_folderName);
        if (_cachedFolderId == null) {
          debugPrint('❌ Failed to resolve Drive folder. Aborting upload.');
          return;
        }
      }

      // Iterate through keys to handle removals safely
      final keys = _queueBox.keys.toList();

      for (final key in keys) {
        final task = Map<String, dynamic>.from(_queueBox.get(key));
        final String interviewId = task['interviewId'];
        final String filePath = task['filePath'];

        debugPrint('🔄 Processing upload for $interviewId...');

        try {
          final file = File(filePath);
          if (!await file.exists()) {
            debugPrint('❌ File not found: $filePath. Removing from queue.');
            await _queueBox.delete(key);
            continue;
          }

          // Verify file is not empty and accessible
          final length = await file.length();
          if (length == 0) {
            debugPrint('⚠️ File is empty: $filePath. Removing from queue.');
            await _queueBox.delete(key);
            continue;
          }

          // 1. Upload to Drive (Pass path, let service handle stream)
          final driveResult = await _driveService.uploadFile(
            file,
            folderId: _cachedFolderId!,
          );
          final driveFileId = driveResult['id']!;
          final driveFileUrl = driveResult['url']!;

          debugPrint('✅ Upload success. Updating database...');

          // 2. Sidecar Sync: Ensure presence in Appwrite (Candidates + Interview Metadata)
          try {
            // A. Sync Candidate
            // Note: We need candidate info. Since queue only has interviewId, and we know
            // the full interview object is in local storage, we ideally need to peek at it.
            // However, to keep this decoupled, we might need to pass candidate info in the queue task
            // OR fetch it from the repository here.
            // Given the constraints, let's fetch the interview from the repository to get the candidate details.
            // Accessing repository here is safe as it's a read operation.

            // To do this clean, we'll need to inject InterviewRepository or pass data in the task.
            // Let's check if we can pass it in the task map for simplicity and isolation.

            final String candidateName =
                task['candidateName'] ?? 'Unknown Candidate';
            final String candidateEmail =
                task['candidateEmail'] ?? 'unknown@candidate.com'; // Fallback
            final String? candidatePhone = task['candidatePhone'];

            debugPrint('🔄 Syncing Sidecar Metadata for $interviewId...');

            // B. Sync Interview Metadata (Handles Candidate Sync internally)
            await _syncRemoteDatasource.syncInterviewMetadata(
              candidateName: candidateName,
              candidateEmail: candidateEmail,
              candidatePhone: candidatePhone,
              interviewId: interviewId,
              driveFileId: driveFileId,
              driveFileUrl: driveFileUrl,
            );

            debugPrint('✅ Sidecar Sync Complete!');
          } catch (e) {
            debugPrint('⚠️ Sidecar Sync Failed (Non-blocking): $e');
            // We do NOT rethrow here because the primary goal (Drive Upload) succeeded.
            // Retrying the whole drive upload just because DB sync failed might be excessive
            // unless strict consistency is required. Given "no trouble" requirement, we log and proceed.
          }

          // 3. Remove from queue on success
          await _queueBox.delete(key);
          debugPrint('✨ Task completed and removed from queue');
        } catch (e) {
          debugPrint('❌ Upload failed for $interviewId: $e');

          // Increment retry count
          int retries = task['retryCount'] ?? 0;
          if (retries >= 5) {
            debugPrint('🚫 Max retries reached. Removing task.');
            await _queueBox.delete(key);
          } else {
            task['retryCount'] = retries + 1;
            await _queueBox.put(key, task);
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error processing upload queue: $e');
    } finally {
      _isProcessRunning = false;
    }
  }

  /// Get count of pending uploads
  int get pendingCount => _queueBox.length;
}
