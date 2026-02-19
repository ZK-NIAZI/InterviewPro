import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:path/path.dart' as path;

/// Service for handling Google Drive uploads using authenticated user credentials
class DriveService {
  drive.DriveApi? _driveApi;

  DriveService();

  drive.DriveApi? get driveApi => _driveApi;

  /// Update the authenticated client (e.g., after sign-in)
  void updateClient(auth.AuthClient? client) {
    if (client != null) {
      _driveApi = drive.DriveApi(client);
      debugPrint('✅ DriveService updated with new authenticated client');
    } else {
      _driveApi = null;
      debugPrint('🔒 DriveService client cleared (User signed out)');
    }
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

  /// Create a unique candidate folder with collision handling
  /// Format: "Name (Suffix)" e.g. "John Doe (AF3K92)"
  Future<String?> createUniqueCandidateFolder(String candidateName) async {
    if (_driveApi == null) return null;

    final baseName = sanitizeFileName(candidateName);
    int attempts = 0;
    const maxAttempts = 5;

    while (attempts < maxAttempts) {
      // 1. Generate Name with Suffix
      final suffix = _generateRandomSuffix();
      final folderName = '$baseName ($suffix)';

      try {
        // 2. Check for existence (Collision Check)
        final query =
            "mimeType = 'application/vnd.google-apps.folder' and name = '$folderName' and trashed = false";
        final fileList = await _driveApi!.files.list(
          q: query,
          $fields: 'files(id)',
        );

        if (fileList.files != null && fileList.files!.isNotEmpty) {
          debugPrint('⚠️ Collision detected for $folderName. Retrying...');
          attempts++;
          continue; // Retry with new suffix
        }

        // 3. Create Folder
        final folderToCreate = drive.File()
          ..name = folderName
          ..mimeType = 'application/vnd.google-apps.folder';

        final createdFolder = await _driveApi!.files.create(
          folderToCreate,
          $fields: 'id, name',
        );

        debugPrint(
          '✅ Created unique candidate folder: "$folderName" (ID: ${createdFolder.id})',
        );
        return createdFolder.id;
      } catch (e) {
        debugPrint('❌ Error creating unique folder: $e');
        return null; // Network or API error, stop retrying
      }
    }

    debugPrint('❌ Failed to create unique folder after $maxAttempts attempts');
    return null;
  }

  /// Generate a 6-character alphanumeric suffix
  String _generateRandomSuffix() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = math.Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
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
