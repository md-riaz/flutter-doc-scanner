import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

final uploadQueueRepositoryProvider = Provider<UploadQueueRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return UploadQueueRepository(database);
});

/// Repository for managing upload queue
class UploadQueueRepository {
  final AppDatabase _database;

  UploadQueueRepository(this._database);

  /// Add document to upload queue
  Future<void> addToQueue(String documentId) async {
    await _database.insertQueueItem(
      UploadQueueCompanion.insert(
        id: documentId, // Use same ID as document for simplicity
        documentId: documentId,
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Get all queue items
  Future<List<UploadQueueData>> getAllQueueItems() async {
    return await _database.getAllQueueItems();
  }

  /// Get pending queue items
  Future<List<UploadQueueData>> getPendingItems() async {
    return await _database.getPendingQueueItems();
  }

  /// Get queue item by ID
  Future<UploadQueueData?> getQueueItem(String id) async {
    return await _database.getQueueItemById(id);
  }

  /// Update queue item status
  Future<void> updateStatus({
    required String id,
    required String status,
    String? errorMessage,
  }) async {
    final item = await _database.getQueueItemById(id);
    if (item != null) {
      await _database.updateQueueItem(
        item.toCompanion(true).copyWith(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
          lastAttemptAt: Value(DateTime.now()),
          errorMessage: Value(errorMessage),
        ),
      );
    }
  }

  /// Increment retry count
  Future<void> incrementRetryCount(String id) async {
    final item = await _database.getQueueItemById(id);
    if (item != null) {
      await _database.updateQueueItem(
        item.toCompanion(true).copyWith(
          retryCount: Value(item.retryCount + 1),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  /// Remove from queue
  Future<void> removeFromQueue(String id) async {
    await _database.deleteQueueItem(id);
  }

  /// Clear completed uploads
  Future<void> clearCompleted() async {
    final allItems = await _database.getAllQueueItems();
    for (final item in allItems) {
      if (item.status == 'uploaded') {
        await _database.deleteQueueItem(item.id);
      }
    }
  }
}
