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

        // 2. OPTIONAL: Update phone if provided and different
        // This makes the system "self-healing" / keeping data fresh
        if (phone != null && phone.isNotEmpty) {
          // We could check if phone is different, but simple update is safe
          try {
            await databases.updateDocument(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.candidatesCollectionId,
              documentId: candidateId,
              data: {'phone': phone},
            );
            debugPrint('🔄 Updated candidate phone for $name ($candidateId)');
          } catch (e) {
            debugPrint(
              '⚠️ Failed to update candidate phone (non-critical): $e',
            );
          }
        }

        return candidateId;
      }

      // 3. Create new candidate if not found
      final documentId = ID.unique();

      final data = {'name': name, 'email': email};

      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }

      debugPrint('📤 Creating candidate with data: $data');

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
    required String interviewId,
    required String driveFileId,
    required String driveFileUrl,
  }) async {
    try {
      final databases = _appwriteService.databases;

      // 1. Sync Candidate (Get ID)
      final candidateId = await syncCandidate(
        name: candidateName,
        email: candidateEmail,
        phone: candidatePhone,
      );

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
