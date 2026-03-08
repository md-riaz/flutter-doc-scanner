import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/upload_item.dart';
import '../providers/upload_queue_provider.dart';

class UploadQueueScreen extends ConsumerWidget {
  const UploadQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(uploadQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Queue'),
        actions: [
          if (queueState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(uploadQueueProvider.notifier).refresh();
              },
              tooltip: 'Refresh',
            ),
          if (queueState.uploadedCount > 0)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                _showClearDialog(context, ref);
              },
              tooltip: 'Clear Uploaded',
            ),
        ],
      ),
      body: _buildBody(context, ref, queueState),
      floatingActionButton: queueState.pendingCount > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                ref.read(uploadQueueProvider.notifier).uploadAll();
              },
              icon: const Icon(Icons.cloud_upload),
              label: Text('Upload All (${queueState.pendingCount})'),
            )
          : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    UploadQueueState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(uploadQueueProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_done,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Upload Queue Empty',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'All documents are synced',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildStatsSummary(context, state),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _buildQueueItem(context, ref, item, state);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(BuildContext context, UploadQueueState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            'Pending',
            state.pendingCount,
            Colors.orange,
          ),
          _buildStatItem(
            context,
            'Uploading',
            state.uploadingCount,
            Colors.blue,
          ),
          _buildStatItem(
            context,
            'Uploaded',
            state.uploadedCount,
            Colors.green,
          ),
          _buildStatItem(
            context,
            'Failed',
            state.failedCount,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildQueueItem(
    BuildContext context,
    WidgetRef ref,
    UploadItem item,
    UploadQueueState state,
  ) {
    final progress = state.uploadProgress[item.documentId] ?? 0.0;

    return Card(
      child: ListTile(
        leading: _buildStatusIcon(item.status),
        title: Text(
          item.documentTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(_buildSubtitle(item)),
            if (item.status == UploadStatus.uploading &&
                progress > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (item.errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                item.errorMessage!,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: _buildActions(context, ref, item),
        isThreeLine: item.errorMessage != null || progress > 0,
      ),
    );
  }

  Widget _buildStatusIcon(UploadStatus status) {
    switch (status) {
      case UploadStatus.pending:
        return const Icon(Icons.schedule, color: Colors.orange);
      case UploadStatus.uploading:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case UploadStatus.uploaded:
        return const Icon(Icons.check_circle, color: Colors.green);
      case UploadStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      case UploadStatus.retrying:
        return const Icon(Icons.refresh, color: Colors.blue);
    }
  }

  String _buildSubtitle(UploadItem item) {
    final statusText = item.status.displayName;
    final retryText =
        item.retryCount > 0 ? ' (Retry ${item.retryCount})' : '';
    return '$statusText$retryText';
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, UploadItem item) {
    switch (item.status) {
      case UploadStatus.pending:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.cloud_upload),
              onPressed: () {
                ref
                    .read(uploadQueueProvider.notifier)
                    .uploadDocument(item.documentId);
              },
              tooltip: 'Upload Now',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteDialog(context, ref, item);
              },
              tooltip: 'Remove',
            ),
          ],
        );
      case UploadStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref
                    .read(uploadQueueProvider.notifier)
                    .retryUpload(item.documentId);
              },
              tooltip: 'Retry',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteDialog(context, ref, item);
              },
              tooltip: 'Remove',
            ),
          ],
        );
      case UploadStatus.uploaded:
        return IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _showDeleteDialog(context, ref, item);
          },
          tooltip: 'Remove',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, UploadItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Queue'),
        content: Text(
          'Remove "${item.documentTitle}" from upload queue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(uploadQueueProvider.notifier).removeFromQueue(item.id);
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Uploaded'),
        content: const Text(
          'Remove all uploaded items from the queue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(uploadQueueProvider.notifier).clearUploaded();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
