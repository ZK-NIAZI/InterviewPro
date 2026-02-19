import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/services/drive_service.dart';
import '../../../../shared/data/datasources/sync_remote_datasource.dart';

import '../../../../core/providers/auth_provider.dart';

enum CvUploadStatus { idle, checking, uploading, success, error }

class CvUploadProvider extends ChangeNotifier {
  final DriveService _driveService;
  final SyncRemoteDatasource _syncRemoteDatasource;
  final AuthProvider _authProvider;

  CvUploadStatus _status = CvUploadStatus.idle;
  String? _cvUrl;
  String? _cvFileId;
  String? _uploadedFolderId;
  String? _errorMessage;

  CvUploadProvider(
    this._driveService,
    this._syncRemoteDatasource,
    this._authProvider,
  );

  CvUploadStatus get status => _status;
  String? get cvUrl => _cvUrl;
  String? get cvFileId => _cvFileId;
  String? get errorMessage => _errorMessage;
  String? get uploadedFolderId => _uploadedFolderId;
  bool get isUploading => _status == CvUploadStatus.uploading;

  // Removed _rootFolderName as we now use per-candidate root folders

  /// Check if candidate already has a CV uploaded
  Future<void> checkExistingCv(String email) async {
    if (email.isEmpty) return;

    _status = CvUploadStatus.checking;
    notifyListeners();

    try {
      final candidateData = await _syncRemoteDatasource.getCandidateByEmail(
        email,
      );
      if (candidateData != null) {
        // Restore CV info
        if (candidateData['cvFileUrl'] != null) {
          _cvUrl = candidateData['cvFileUrl'];
          _cvFileId = candidateData['cvFileId'];
          _status = CvUploadStatus.success;
        }

        // Restore Folder ID (Critical for consistency)
        if (candidateData['driveFolderId'] != null) {
          _uploadedFolderId = candidateData['driveFolderId'];
          debugPrint('📂 Restored existing Drive Folder: $_uploadedFolderId');
        }
      } else {
        _status = CvUploadStatus.idle;
      }
    } catch (e) {
      debugPrint('⚠️ Error checking existing CV: $e');
      _status = CvUploadStatus.idle;
    }
    notifyListeners();
  }

  /// Upload CV file to Drive and link to Appwrite
  Future<void> uploadCv({
    required File file,
    required String candidateName,
    required String candidateEmail,
    String? candidatePhone,
  }) async {
    // 1. Connectivity Check (Fail Fast)
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.every((result) => result == ConnectivityResult.none)) {
      _setError('No internet connection. Please try again when online.');
      return;
    }

    // 2. File Size Check (Prevent large uploads)
    final length = await file.length();
    if (length > 10 * 1024 * 1024) {
      // 10MB
      _setError('File size exceeds 10MB limit.');
      return;
    }

    _status = CvUploadStatus.uploading;
    _errorMessage = null;
    notifyListeners();

    try {
      // 3. Authenticate Drive Service
      final client = await _authProvider.getAuthenticatedClient();
      if (client != null) {
        _driveService.updateClient(client);
      } else {
        throw Exception('User not signed in to Google Drive');
      }

      // 4. Get/Create Candidate Folder (Unique Strategy)
      // Use existing folder if restored, or check DB, otherwise create new unique one
      String? candidateFolderId = _uploadedFolderId;

      // If not locally cached, check DB first (Deduplication)
      if (candidateFolderId == null) {
        try {
          final existingCandidate = await _syncRemoteDatasource
              .getCandidateByEmail(candidateEmail);
          if (existingCandidate != null) {
            final existingId = existingCandidate['driveFolderId'];
            if (existingId != null && existingId.toString().isNotEmpty) {
              candidateFolderId = existingId;
              debugPrint(
                '♻️ Reusing existing Drive Folder ID for CV Upload: $candidateFolderId',
              );
            }
          }
        } catch (e) {
          debugPrint('⚠️ Error checking existing candidate for CV upload: $e');
        }
      }

      // Only create new if we still don't have an ID
      candidateFolderId ??= await _driveService.createUniqueCandidateFolder(
        candidateName,
      );

      if (candidateFolderId == null) {
        throw Exception('Could not create candidate folder');
      }

      // 5. Prepare Filename
      // Format: {CandidateName}_CV.{extension}
      final extension = file.path.split('.').last;
      final safeName = DriveService.sanitizeFileName(candidateName);
      final targetFileName = '${safeName}_CV.$extension';

      // 6. Upload File
      final result = await _driveService.uploadFile(
        file,
        folderId: candidateFolderId,
        targetFileName: targetFileName,
      );
      final driveFileId = result['id']!;
      final driveFileUrl = result['url']!;

      // 6. Sync with Appwrite (Persist ALL IDs)
      await _syncRemoteDatasource.syncCandidate(
        name: candidateName,
        email: candidateEmail,
        phone: candidatePhone,
        cvFileId: driveFileId,
        cvFileUrl: driveFileUrl,
        driveFolderId: candidateFolderId, // CRITICAL: Save folder ID
      );

      _cvUrl = driveFileUrl;
      _cvFileId = driveFileId;
      _uploadedFolderId = candidateFolderId;
      _status = CvUploadStatus.success;
      debugPrint('✅ CV Uploaded Successfully: $driveFileUrl');
    } catch (e) {
      debugPrint('❌ CV Upload Failed: $e');
      _setError('Failed to upload CV: ${e.toString()}');
      _status = CvUploadStatus.error;
    } // Status will be updated via _setError or success path
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = CvUploadStatus.error;
    notifyListeners();
  }

  void reset() {
    _status = CvUploadStatus.idle;
    _errorMessage = null;
    _cvUrl = null;
    _cvFileId = null;
    _uploadedFolderId = null;
    notifyListeners();
  }
}
