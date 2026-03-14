import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class LiveRoomMediaUploadResult {
  final bool success;
  final String? storagePath;
  final String? downloadUrl;
  final String? fileName;
  final String? errorMessage;

  const LiveRoomMediaUploadResult({
    required this.success,
    this.storagePath,
    this.downloadUrl,
    this.fileName,
    this.errorMessage,
  });

  const LiveRoomMediaUploadResult.error(String message)
    : success = false,
      storagePath = null,
      downloadUrl = null,
      fileName = null,
      errorMessage = message;
}

class LiveRoomMediaStorageService {
  LiveRoomMediaStorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  static const int _maxImageBytes = 10 * 1024 * 1024;

  Future<LiveRoomMediaUploadResult> uploadRoomImage({
    required String userId,
    required String kind,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final safeUserId = userId.trim();
    if (safeUserId.isEmpty) {
      return const LiveRoomMediaUploadResult.error(
        'Please sign in before uploading room images.',
      );
    }

    final safeKind = kind.trim().toLowerCase();
    if (safeKind.isEmpty) {
      return const LiveRoomMediaUploadResult.error('Upload kind is required.');
    }

    if (fileBytes.isEmpty) {
      return const LiveRoomMediaUploadResult.error(
        'Could not read the selected image.',
      );
    }
    if (fileBytes.length > _maxImageBytes) {
      return const LiveRoomMediaUploadResult.error(
        'Image must be 10 MB or smaller.',
      );
    }

    final normalizedName = fileName.trim().isEmpty
        ? '$safeKind.jpg'
        : fileName.trim();
    final extension = _resolveExtension(normalizedName);
    final mimeType = _resolveMimeType(extension);
    if (mimeType == null) {
      return const LiveRoomMediaUploadResult.error(
        'Only JPG, PNG, and WEBP images are supported.',
      );
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath =
        'live_room_media/$safeUserId/${safeKind}_$timestamp.$extension';

    try {
      final ref = _storage.ref(storagePath);
      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: <String, String>{
          'uploaded_by': safeUserId,
          'kind': safeKind,
          'original_name': normalizedName,
          'uploaded_at': DateTime.now().toUtc().toIso8601String(),
        },
      );

      await ref.putData(fileBytes, metadata);
      final downloadUrl = await ref.getDownloadURL();

      return LiveRoomMediaUploadResult(
        success: true,
        storagePath: storagePath,
        downloadUrl: downloadUrl,
        fileName: normalizedName,
      );
    } on FirebaseException catch (error) {
      return LiveRoomMediaUploadResult.error(_formatStorageError(error));
    } catch (error) {
      return LiveRoomMediaUploadResult.error('Upload failed: $error');
    }
  }

  Future<void> deleteImage(String storagePath) async {
    final normalizedPath = storagePath.trim();
    if (normalizedPath.isEmpty) return;
    try {
      await _storage.ref(normalizedPath).delete();
    } on FirebaseException {
      // Best-effort cleanup only.
    }
  }

  String _resolveExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length < 2) return 'jpg';
    final ext = parts.last.trim().toLowerCase();
    if (ext.isEmpty) return 'jpg';
    return ext == 'jpeg' ? 'jpg' : ext;
  }

  String? _resolveMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return null;
    }
  }

  String _formatStorageError(FirebaseException error) {
    switch (error.code) {
      case 'unauthorized':
        return 'Upload failed. Check that your Firebase Storage rules allow room image uploads.';
      case 'bucket-not-found':
      case 'no-default-bucket':
        return 'Upload failed. Firebase Storage is not configured.';
      case 'canceled':
        return 'Upload canceled.';
      default:
        final message = error.message?.trim();
        if (message != null && message.isNotEmpty) {
          return 'Upload failed (${error.code}): $message';
        }
        return 'Upload failed (${error.code}).';
    }
  }
}
