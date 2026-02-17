import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:path/path.dart' as path;

/// Service for handling Google Drive uploads using authenticated user credentials
class DriveService {
  drive.DriveApi? _driveApi;

  /// The authenticated HTTP client from Google Sign-In
  final auth.AuthClient? _authClient;

  DriveService(this._authClient) {
    if (_authClient != null) {
      _driveApi = drive.DriveApi(_authClient);
    }
  }

  /// Update the authenticated client (e.g., after sign-in)
  void updateClient(auth.AuthClient client) {
    _driveApi = drive.DriveApi(client);
    debugPrint('✅ DriveService updated with new authenticated client');
  }

  /// Check if a folder exists, create it if not, and return its ID
  /// Supports optional [parentFolderId] for nested folders
  Future<String?> getOrCreateFolder(
    String folderName, {
    String? parentFolderId,
  }) async {
    if (_driveApi == null) return null;

    try {
      // 1. Search for folder
      var query =
          "mimeType = 'application/vnd.google-apps.folder' and name = '$folderName' and trashed = false";

      if (parentFolderId != null) {
        query += " and '$parentFolderId' in parents";
      }

      final fileList = await _driveApi!.files.list(
        q: query,
        $fields: 'files(id, name)',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final folderId = fileList.files!.first.id;
        debugPrint(
          '📂 Found existing folder "$folderName" (ID: $folderId) ${parentFolderId != null ? 'in parent $parentFolderId' : ''}',
        );
        return folderId;
      }

      // 2. Create if not found
      final folderToCreate = drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder';

      if (parentFolderId != null) {
        folderToCreate.parents = [parentFolderId];
      }

      final createdFolder = await _driveApi!.files.create(
        folderToCreate,
        $fields: 'id, name',
      );
      debugPrint(
        'mw New folder created "$folderName" (ID: ${createdFolder.id})',
      );
      return createdFolder.id;
    } catch (e) {
      debugPrint('❌ Error getting/creating folder: $e');
      return null;
    }
  }

  /// Sanitize a file/folder name to be safe for Drive and File Systems
  static String sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
  }

  /// Upload a file to Google Drive with retries
  /// Returns the file ID and View URL
  Future<Map<String, String>> uploadFile(
    File file, {
    required String folderId,
    String? targetFileName,
  }) async {
    if (_driveApi == null) {
      throw Exception(
        'User not signed in. Please connect to Google Drive first.',
      );
    }

    // Pass the File object so we can recreate streams on retry
    return _uploadWithRetry(
      file,
      folderId: folderId,
      targetFileName: targetFileName,
    );
  }

  /// Internal method to handle exponential backoff for uploads
  Future<Map<String, String>> _uploadWithRetry(
    File file, {
    String? folderId,
    String? targetFileName,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final fileName = targetFileName ?? path.basename(file.path);
        final length = await file.length();

        // CORTEX-FIX: Open stream fresh for each attempt
        final stream = file.openRead();
        final media = drive.Media(stream, length);

        final driveFile = drive.File()..name = fileName;

        // Use folderId if provided
        if (folderId != null && folderId.isNotEmpty) {
          driveFile.parents = [folderId];
        }

        final result = await _driveApi!.files.create(
          driveFile,
          uploadMedia: media,
          $fields: 'id, webViewLink, name',
        );

        debugPrint('☁️ Uploaded to Drive: ${result.name} (ID: ${result.id})');

        return {'id': result.id!, 'url': result.webViewLink!};
      } catch (e) {
        attempts++;
        debugPrint(
          '⚠️ Drive upload failed (Attempt $attempts/$maxRetries): $e',
        );

        if (attempts >= maxRetries) {
          rethrow;
        }

        // Exponential backoff: 1s, 2s, 4s
        await Future.delayed(Duration(seconds: (1 << (attempts - 1))));
      }
    }
    throw Exception('Upload failed after $maxRetries attempts');
  }
}
