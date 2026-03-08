import 'dart:io';

/// Mock API client for document uploads (for testing without backend)
class MockUploadApi {
  /// Simulate upload delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  /// Mock upload document to server
  ///
  /// Simulates successful upload with 90% success rate
  /// Returns mock server response
  Future<Map<String, dynamic>> uploadDocument({
    required String documentPath,
    required String title,
    String? category,
    List<String>? tags,
    String? projectId,
    String? folderId,
    void Function(int sent, int total)? onProgress,
  }) async {
    // Check if file exists
    final file = File(documentPath);
    if (!await file.exists()) {
      throw Exception('File not found: $documentPath');
    }

    // Simulate progress updates
    if (onProgress != null) {
      final fileSize = await file.length();
      for (int i = 0; i <= 100; i += 20) {
        await Future.delayed(const Duration(milliseconds: 400));
        onProgress((fileSize * i ~/ 100), fileSize);
      }
    } else {
      await _simulateDelay();
    }

    // Simulate 90% success rate
    final random = DateTime.now().millisecondsSinceEpoch % 10;
    if (random < 1) {
      throw Exception('Mock network error: Connection timeout');
    }

    // Return mock success response
    final documentId = 'doc_${DateTime.now().millisecondsSinceEpoch}';
    return {
      'success': true,
      'message': 'Document uploaded successfully',
      'data': {
        'id': documentId,
        'title': title,
        'category': category,
        'tags': tags,
        'project_id': projectId,
        'folder_id': folderId,
        'file_size': await file.length(),
        'uploaded_at': DateTime.now().toIso8601String(),
        'status': 'uploaded',
      },
    };
  }

  /// Mock get upload status
  Future<Map<String, dynamic>> getUploadStatus(String documentId) async {
    await _simulateDelay();

    return {
      'success': true,
      'data': {
        'id': documentId,
        'status': 'uploaded',
        'uploaded_at': DateTime.now().toIso8601String(),
      },
    };
  }

  /// Mock delete document
  Future<void> deleteDocument(String documentId) async {
    await _simulateDelay();
    // Mock successful deletion
  }
}
