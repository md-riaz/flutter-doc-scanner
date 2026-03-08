/// Domain entity representing an upload item
class UploadItem {
  final String id;
  final String documentId;
  final String documentPath;
  final String documentTitle;
  final UploadStatus status;
  final int retryCount;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;

  const UploadItem({
    required this.id,
    required this.documentId,
    required this.documentPath,
    required this.documentTitle,
    required this.status,
    this.retryCount = 0,
    this.errorMessage,
    required this.createdAt,
    this.lastAttemptAt,
  });

  UploadItem copyWith({
    String? id,
    String? documentId,
    String? documentPath,
    String? documentTitle,
    UploadStatus? status,
    int? retryCount,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
  }) {
    return UploadItem(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentPath: documentPath ?? this.documentPath,
      documentTitle: documentTitle ?? this.documentTitle,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }
}

/// Upload status enum
enum UploadStatus {
  pending,
  uploading,
  uploaded,
  failed,
  retrying;

  String get displayName {
    switch (this) {
      case UploadStatus.pending:
        return 'Pending';
      case UploadStatus.uploading:
        return 'Uploading';
      case UploadStatus.uploaded:
        return 'Uploaded';
      case UploadStatus.failed:
        return 'Failed';
      case UploadStatus.retrying:
        return 'Retrying';
    }
  }

  /// Convert from string
  static UploadStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return UploadStatus.pending;
      case 'uploading':
        return UploadStatus.uploading;
      case 'uploaded':
        return UploadStatus.uploaded;
      case 'failed':
        return UploadStatus.failed;
      case 'retrying':
        return UploadStatus.retrying;
      default:
        return UploadStatus.pending;
    }
  }
}
