import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/mock_upload_api.dart';
import '../datasources/upload_api.dart';

final uploadServiceProvider = Provider<UploadService>((ref) {
  final uploadApi = ref.watch(uploadApiProvider);
  return UploadService(uploadApi);
});

/// Service for handling document uploads with retry logic
class UploadService {
  final UploadApi? _uploadApi;
  final MockUploadApi _mockUploadApi = MockUploadApi();
  final Connectivity _connectivity = Connectivity();

  UploadService(this._uploadApi);

  /// Max retry attempts
  static const int maxRetries = 3;

  /// Retry delay in seconds
  static const int retryDelay = 5;

  /// Check if network is available
  Future<bool> isNetworkAvailable() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      // If connectivity check fails, assume network is available
      return true;
    }
  }

  /// Upload document with retry logic
  ///
  /// Parameters:
  /// - documentPath: Local file path of the document
  /// - title: Document title
  /// - category: Document category (optional)
  /// - tags: Document tags (optional)
  /// - projectId: Project ID (optional)
  /// - folderId: Folder ID (optional)
  /// - onProgress: Progress callback (sent, total)
  /// - retryCount: Current retry attempt (internal use)
  ///
  /// Returns:
  /// - Map with upload response data
  ///
  /// Throws:
  /// - Exception if upload fails after all retries
  Future<Map<String, dynamic>> uploadDocument({
    required String documentPath,
    required String title,
    String? category,
    List<String>? tags,
    String? projectId,
    String? folderId,
    void Function(int sent, int total)? onProgress,
    int retryCount = 0,
  }) async {
    try {
      // Check if file exists
      final file = File(documentPath);
      if (!await file.exists()) {
        throw Exception('File not found: $documentPath');
      }

      // Check network connectivity
      if (!await isNetworkAvailable()) {
        throw Exception('No network connection available');
      }

      // Use mock API or real API based on configuration
      if (AppConstants.useMockApi) {
        return await _mockUploadApi.uploadDocument(
          documentPath: documentPath,
          title: title,
          category: category,
          tags: tags,
          projectId: projectId,
          folderId: folderId,
          onProgress: onProgress,
        );
      } else {
        if (_uploadApi == null) {
          throw Exception('Upload API not configured');
        }
        return await _uploadApi!.uploadDocument(
          documentPath: documentPath,
          title: title,
          category: category,
          tags: tags,
          projectId: projectId,
          folderId: folderId,
          onProgress: onProgress,
        );
      }
    } catch (e) {
      // Retry logic
      if (retryCount < maxRetries) {
        // Wait before retrying
        await Future.delayed(Duration(seconds: retryDelay * (retryCount + 1)));

        // Retry upload
        return await uploadDocument(
          documentPath: documentPath,
          title: title,
          category: category,
          tags: tags,
          projectId: projectId,
          folderId: folderId,
          onProgress: onProgress,
          retryCount: retryCount + 1,
        );
      } else {
        // Max retries reached, throw exception
        throw Exception('Upload failed after $maxRetries attempts: $e');
      }
    }
  }

  /// Get upload status
  Future<Map<String, dynamic>> getUploadStatus(String documentId) async {
    if (AppConstants.useMockApi) {
      return await _mockUploadApi.getUploadStatus(documentId);
    } else {
      if (_uploadApi == null) {
        throw Exception('Upload API not configured');
      }
      return await _uploadApi!.getUploadStatus(documentId);
    }
  }

  /// Delete document from server
  Future<void> deleteDocument(String documentId) async {
    if (AppConstants.useMockApi) {
      return await _mockUploadApi.deleteDocument(documentId);
    } else {
      if (_uploadApi == null) {
        throw Exception('Upload API not configured');
      }
      return await _uploadApi!.deleteDocument(documentId);
    }
  }

  /// Validate document for upload
  ///
  /// Checks:
  /// - File exists
  /// - File size is within limits
  /// - File is a PDF
  Future<bool> validateDocument(String documentPath) async {
    try {
      final file = File(documentPath);

      // Check if file exists
      if (!await file.exists()) {
        return false;
      }

      // Check file extension
      if (!documentPath.toLowerCase().endsWith('.pdf')) {
        return false;
      }

      // Check file size (max 50MB)
      final fileSize = await file.length();
      const maxSize = 50 * 1024 * 1024; // 50MB
      if (fileSize > maxSize) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
