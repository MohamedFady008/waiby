import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../core/validators/creator_validators.dart';

/// Result of an identity document upload operation.
class IdentityUploadResult {
  final bool success;
  final String? storagePath;
  final String? downloadUrl;
  final String? errorMessage;

  const IdentityUploadResult({
    required this.success,
    this.storagePath,
    this.downloadUrl,
    this.errorMessage,
  });

  const IdentityUploadResult.error(String message)
    : success = false,
      storagePath = null,
      downloadUrl = null,
      errorMessage = message;
}

/// Service responsible for uploading identity verification documents
/// to Firebase Storage.
class CreatorStorageService {
  CreatorStorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Upload path prefix for identity documents.
  static const String _basePath = 'creator_identity_documents';

  /// Uploads an identity document for the given [userId].
  ///
  /// Performs pre-upload validation on file name, size, and MIME type.
  /// Returns an [IdentityUploadResult] with the storage path and download URL
  /// on success, or an error message on failure.
  Future<IdentityUploadResult> uploadIdentityDocument({
    required String userId,
    required String fileName,
    required Uint8List fileBytes,
    required String? mimeType,
  }) async {
    // ── Pre-upload validation ────────────────────────────────────────
    final extError = CreatorValidators.validateFileExtension(fileName);
    if (extError != null) return IdentityUploadResult.error(extError);

    final sizeError = CreatorValidators.validateFileSize(fileBytes.length);
    if (sizeError != null) return IdentityUploadResult.error(sizeError);

    final mimeError = CreatorValidators.validateMimeType(mimeType);
    if (mimeError != null) return IdentityUploadResult.error(mimeError);

    // ── Build storage path ───────────────────────────────────────────
    final ext = fileName.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = '$_basePath/$userId/identity_$timestamp.$ext';

    try {
      final ref = _storage.ref(storagePath);

      // Set metadata for the upload.
      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: <String, String>{
          'uploaded_by': userId,
          'original_name': fileName,
          'uploaded_at': DateTime.now().toUtc().toIso8601String(),
        },
      );

      // Upload the file bytes.
      await ref.putData(fileBytes, metadata);

      // Retrieve the download URL.
      final downloadUrl = await ref.getDownloadURL();

      return IdentityUploadResult(
        success: true,
        storagePath: storagePath,
        downloadUrl: downloadUrl,
      );
    } on FirebaseException catch (e) {
      return IdentityUploadResult.error(
        'Upload failed: ${e.message ?? e.code}',
      );
    } catch (e) {
      return IdentityUploadResult.error('Unexpected upload error: $e');
    }
  }

  /// Deletes a previously uploaded identity document.
  Future<void> deleteDocument(String storagePath) async {
    try {
      await _storage.ref(storagePath).delete();
    } on FirebaseException {
      // Silently ignore if the file doesn't exist.
    }
  }
}
