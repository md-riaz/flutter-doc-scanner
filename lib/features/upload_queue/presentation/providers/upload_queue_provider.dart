import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/upload_item.dart';
import '../../data/services/upload_service.dart';
import '../../data/repositories/upload_queue_repository.dart';
import '../../../documents/data/repositories/document_repository.dart';

/// Provider for upload queue state
final uploadQueueProvider =
    StateNotifierProvider<UploadQueueNotifier, UploadQueueState>((ref) {
  final uploadService = ref.watch(uploadServiceProvider);
  final queueRepository = ref.watch(uploadQueueRepositoryProvider);
  final documentRepository = ref.watch(documentRepositoryProvider);

  return UploadQueueNotifier(
    uploadService: uploadService,
    queueRepository: queueRepository,
    documentRepository: documentRepository,
  );
});

/// State for upload queue
class UploadQueueState {
  final List<UploadItem> items;
  final bool isLoading;
  final String? error;
  final Map<String, double> uploadProgress; // documentId -> progress (0.0-1.0)

  const UploadQueueState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.uploadProgress = const {},
  });

  UploadQueueState copyWith({
    List<UploadItem>? items,
    bool? isLoading,
    String? error,
    Map<String, double>? uploadProgress,
  }) {
    return UploadQueueState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  /// Get pending items count
  int get pendingCount =>
      items.where((item) => item.status == UploadStatus.pending).length;

  /// Get uploading items count
  int get uploadingCount =>
      items.where((item) => item.status == UploadStatus.uploading).length;

  /// Get failed items count
  int get failedCount =>
      items.where((item) => item.status == UploadStatus.failed).length;

  /// Get uploaded items count
  int get uploadedCount =>
      items.where((item) => item.status == UploadStatus.uploaded).length;
}

/// Notifier for managing upload queue
class UploadQueueNotifier extends StateNotifier<UploadQueueState> {
  final UploadService uploadService;
  final UploadQueueRepository queueRepository;
  final DocumentRepository documentRepository;

  UploadQueueNotifier({
    required this.uploadService,
    required this.queueRepository,
    required this.documentRepository,
  }) : super(const UploadQueueState()) {
    loadQueue();
  }

  /// Load queue from database
  Future<void> loadQueue() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final queueItems = await queueRepository.getAllQueueItems();
      final uploadItems = <UploadItem>[];

      for (final queueItem in queueItems) {
        // Get document details
        final document =
            await documentRepository.getDocumentById(queueItem.documentId);

        if (document != null) {
          uploadItems.add(UploadItem(
            id: queueItem.id,
            documentId: queueItem.documentId,
            documentPath: document.filePath,
            documentTitle: document.title,
            status: UploadStatus.fromString(queueItem.status),
            retryCount: queueItem.retryCount,
            errorMessage: queueItem.errorMessage,
            createdAt: queueItem.createdAt,
            lastAttemptAt: queueItem.lastAttemptAt,
          ));
        }
      }

      state = state.copyWith(items: uploadItems, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load queue: $e',
      );
    }
  }

  /// Add document to upload queue
  Future<void> addToQueue(String documentId) async {
    try {
      await queueRepository.addToQueue(documentId);
      await loadQueue();
    } catch (e) {
      state = state.copyWith(error: 'Failed to add to queue: $e');
    }
  }

  /// Upload a specific document
  Future<void> uploadDocument(String documentId) async {
    try {
      // Find the upload item
      final item = state.items.firstWhere((i) => i.documentId == documentId);

      // Update status to uploading
      await queueRepository.updateStatus(
        id: item.id,
        status: 'uploading',
      );
      await loadQueue();

      // Get document details
      final document = await documentRepository.getDocumentById(documentId);
      if (document == null) {
        throw Exception('Document not found');
      }

      // Upload with progress tracking
      await uploadService.uploadDocument(
        documentPath: document.filePath,
        title: document.title,
        category: document.category,
        tags: document.tags,
        projectId: document.projectId,
        onProgress: (sent, total) {
          final progress = sent / total;
          state = state.copyWith(
            uploadProgress: {...state.uploadProgress, documentId: progress},
          );
        },
      );

      // Update status to uploaded
      await queueRepository.updateStatus(
        id: item.id,
        status: 'uploaded',
      );

      // Remove progress
      final newProgress = Map<String, double>.from(state.uploadProgress);
      newProgress.remove(documentId);
      state = state.copyWith(uploadProgress: newProgress);

      await loadQueue();
    } catch (e) {
      // Update status to failed
      final item = state.items.firstWhere((i) => i.documentId == documentId);
      await queueRepository.updateStatus(
        id: item.id,
        status: 'failed',
        errorMessage: e.toString(),
      );
      await queueRepository.incrementRetryCount(item.id);

      // Remove progress
      final newProgress = Map<String, double>.from(state.uploadProgress);
      newProgress.remove(documentId);
      state = state.copyWith(uploadProgress: newProgress);

      await loadQueue();
      state = state.copyWith(error: 'Upload failed: $e');
    }
  }

  /// Upload all pending documents
  Future<void> uploadAll() async {
    final pendingItems =
        state.items.where((item) => item.status == UploadStatus.pending);

    for (final item in pendingItems) {
      await uploadDocument(item.documentId);
    }
  }

  /// Retry failed upload
  Future<void> retryUpload(String documentId) async {
    await uploadDocument(documentId);
  }

  /// Remove item from queue
  Future<void> removeFromQueue(String id) async {
    try {
      await queueRepository.removeFromQueue(id);
      await loadQueue();
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove from queue: $e');
    }
  }

  /// Clear all uploaded items
  Future<void> clearUploaded() async {
    try {
      await queueRepository.clearCompleted();
      await loadQueue();
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear uploaded: $e');
    }
  }

  /// Refresh queue
  Future<void> refresh() async {
    await loadQueue();
  }
}
