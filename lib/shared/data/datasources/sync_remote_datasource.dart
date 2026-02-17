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
  }) async {
    try {
      final databases = _appwriteService.databases;

      // 1. Check if candidate exists by email
      final response = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.candidatesCollectionId,
        queries: [Query.equal('email', email), Query.limit(1)],
      );

      if (response.documents.isNotEmpty) {
        final existingId = response.documents.first.$id;
        debugPrint('✅ Found existing candidate: $name ($existingId)');
        return existingId;
      }

      // 2. Create new candidate if not found
      final newDoc = await databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.candidatesCollectionId,
        documentId: ID.unique(),
        data: {'name': name, 'email': email},
      );

      debugPrint('✨ Created new candidate: $name (${newDoc.$id})');
      return newDoc.$id;
    } catch (e) {
      debugPrint('❌ Error syncing candidate: $e');
      rethrow;
    }
  }

  /// Sync Interview Metadata (Drive Links + Candidate Link)
  /// Uses the Interview ID as the Document ID to ensure 1:1 mapping
  Future<void> syncInterviewMetadata({
    required String interviewId,
    required String candidateId,
    required String driveFileId,
    required String driveFileUrl,
    required String candidateName,
    required DateTime createdTime,
  }) async {
    try {
      final databases = _appwriteService.databases;

      // Check if document exists first (idempotency)
      try {
        await databases.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.interviewsCollectionId,
          documentId: interviewId,
        );

        // Update if exists
        await databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.interviewsCollectionId,
          documentId: interviewId,
          data: {
            'candidateId': candidateId,
            'driveFileId': driveFileId,
            'driveFileUrl': driveFileUrl,
          },
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
}
