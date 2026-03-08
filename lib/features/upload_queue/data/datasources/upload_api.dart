import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

final uploadApiProvider = Provider<UploadApi>((ref) {
  final dio = ref.watch(dioClientProvider);
  return UploadApi(dio);
});

/// API client for document uploads
class UploadApi {
  final Dio _dio;

  UploadApi(this._dio);

  /// Upload document to server
  ///
  /// Parameters:
  /// - documentPath: Local file path of the document
  /// - title: Document title
  /// - category: Document category (optional)
  /// - tags: Document tags (optional)
  /// - projectId: Project ID (optional)
  /// - folderId: Folder ID (optional)
  ///
  /// Returns:
  /// - Map with upload response data
  Future<Map<String, dynamic>> uploadDocument({
    required String documentPath,
    required String title,
    String? category,
    List<String>? tags,
    String? projectId,
    String? folderId,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final file = File(documentPath);
      if (!await file.exists()) {
        throw Exception('File not found: $documentPath');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          documentPath,
          filename: documentPath.split('/').last,
        ),
        'title': title,
        if (category != null) 'category': category,
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
        if (projectId != null) 'project_id': projectId,
        if (folderId != null) 'folder_id': folderId,
      });

      final response = await _dio.post(
        ApiEndpoints.documentUpload,
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Upload failed: ${e.response?.data['message'] ?? e.message}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  /// Get upload status
  Future<Map<String, dynamic>> getUploadStatus(String documentId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.documentDetail(documentId),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get upload status: $e');
    }
  }

  /// Delete document from server
  Future<void> deleteDocument(String documentId) async {
    try {
      await _dio.delete(ApiEndpoints.documentDetail(documentId));
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
}
