import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/config/appwrite_config.dart';
import '../../../../core/services/appwrite_service.dart';

/// Dedicated datasource for sync operations to keep "Sidecar" logic isolated
class SyncRemoteDatasource {
  final AppwriteService _appwriteService;

  SyncRemoteDatasource(this._appwriteService);

  /// Get or Create a Candidate in Appwrite
  /// Returns the Candidate ID
  Future<String> syncCandidate({
    required String name,
    required String email,
    String? phone,
    String? cvFileId,
    String? cvFileUrl,
    String? driveFolderId,
  }) async {
    try {
      final databases = _appwriteService.databases;

      // 1. Check if candidate exists by email (Unique Key)
      final existingCandidates = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.candidatesCollectionId,
        queries: [Query.equal('email', email)],
      );

      if (existingCandidates.documents.isNotEmpty) {
        final candidate = existingCandidates.documents.first;
        final candidateId = candidate.$id;
        debugPrint('✅ Found existing candidate: $name ($candidateId)');

        final data = <String, dynamic>{
          'name': name,
          'phone': phone ?? candidate.data['phone'],
        };

        // Update CV info if provided
        if (cvFileId != null) data['cvFileId'] = cvFileId;
        if (cvFileUrl != null) data['cvFileUrl'] = cvFileUrl;
        // Update Drive Folder ID if provided (Persist unique folder)
        if (driveFolderId != null) data['driveFolderId'] = driveFolderId;

        await databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.candidatesCollectionId,
          documentId: candidateId,
          data: data,
        );
        debugPrint('🔄 Updated candidate for $name ($candidateId)');
        return candidateId;
      }

      // 2. Create new candidate if not found
      final documentId = ID.unique();
      final data = {
        'name': name,
        'email': email,
        'phone': phone,
        'cvFileId': cvFileId,
        'cvFileUrl': cvFileUrl,
        'driveFolderId': driveFolderId,
      };

      await databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.candidatesCollectionId,
        documentId: documentId,
        data: data,
      );

      debugPrint('✨ Created new candidate: $name ($documentId)');
      return documentId;
    } on AppwriteException catch (e) {
      debugPrint(
        '❌ Sync Candidate Appwrite Error: ${e.message} (Code: ${e.code}, Type: ${e.type})',
      );
      rethrow;
    } catch (e) {
      debugPrint('❌ Sync Candidate Unknown Error: $e');
      rethrow;
    }
  }

  /// Sync Interview Metadata (Drive Links + Candidate Link)
  /// Uses the Interview ID as the Document ID to ensure 1:1 mapping
  Future<void> syncInterviewMetadata({
    required String candidateName,
    required String candidateEmail,
    String? candidatePhone,
    String? candidateCvId,
    String? candidateCvUrl,
    required String interviewId,
    required String driveFileId,
    required String driveFileUrl,
    String? driveFolderId,
  }) async {
    try {
      final databases = _appwriteService.databases;

      // 1. Sync Candidate (Get ID)
      final candidateId = await syncCandidate(
        name: candidateName,
        email: candidateEmail,
        phone: candidatePhone,
        cvFileId: candidateCvId,
        cvFileUrl: candidateCvUrl,
        driveFolderId: driveFolderId,
      );

      // Check if document exists first (idempotency)
      try {
        await databases.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.interviewsCollectionId,
          documentId: interviewId,
        );

        // Update if exists
        final data = <String, dynamic>{
          'candidateId': candidateId,
          'driveFileId': driveFileId,
          'driveFileUrl': driveFileUrl,
        };
        if (driveFolderId != null) data['driveFolderId'] = driveFolderId;

        await databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.interviewsCollectionId,
          documentId: interviewId,
          data: data,
        );
        debugPrint('🔄 Updated existing interview metadata: $interviewId');
      } catch (e) {
        // Create if not exists (Expected flow for new interviews in this sidecar pattern)
        if (e is AppwriteException && e.code == 404) {
          await databases.createDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.interviewsCollectionId,
            documentId: interviewId,
            data: {
              'candidateId': candidateId,
              'driveFileId': driveFileId,
              'driveFileUrl': driveFileUrl,
              'driveFolderId': driveFolderId,
            },
          );
          debugPrint('✨ Created new interview metadata record: $interviewId');
        } else {
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('❌ Error syncing interview metadata: $e');
      rethrow;
    }
  }

  /// Get candidate by email (to check for existing CV)
  Future<Map<String, dynamic>?> getCandidateByEmail(String email) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.candidatesCollectionId,
        queries: [Query.equal('email', email)],
      );

      if (response.documents.isNotEmpty) {
        return response.documents.first.data;
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Error retrieving candidate: $e');
      return null;
    }
  }
}
