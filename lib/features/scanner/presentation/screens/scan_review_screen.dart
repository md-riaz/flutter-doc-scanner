import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/scan_session_provider.dart';
import '../../domain/entities/scanned_page.dart';

class ScanReviewScreen extends ConsumerWidget {
  const ScanReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(scanSessionProvider);
    final session = sessionState.session;

    if (session == null || session.pages.isEmpty) {
      // Redirect back if no pages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${session.pages.length} Pages'),
        actions: [
          IconButton(
            onPressed: () {
              // Add more pages
              context.push('/scanner/camera');
            },
            icon: const Icon(Icons.add_a_photo),
            tooltip: 'Add Pages',
          ),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: session.pages.length,
        onReorder: (oldIndex, newIndex) {
          ref.read(scanSessionProvider.notifier).reorderPages(
                oldIndex,
                newIndex,
              );
        },
        itemBuilder: (context, index) {
          final page = session.pages[index];
          return _PageListItem(
            key: ValueKey(page.id),
            page: page,
            onTap: () {
              _showPageDetail(context, ref, page);
            },
            onEdit: () {
              context.push('/scanner/preview?pageId=${page.id}');
            },
            onRotateLeft: () {
              ref.read(scanSessionProvider.notifier).rotatePage(page.id, -90);
            },
            onRotateRight: () {
              ref.read(scanSessionProvider.notifier).rotatePage(page.id, 90);
            },
            onDelete: () {
              _confirmDelete(context, ref, page);
            },
            onDuplicate: () {
              ref.read(scanSessionProvider.notifier).duplicatePage(page.id);
            },
            onReplace: () {
              _replacePage(context, ref, page);
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: sessionState.isLoading
              ? null
              : () {
                  // Navigate to PDF generation
                  context.push('/pdf/generate');
                },
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Generate PDF'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  void _showPageDetail(BuildContext context, WidgetRef ref, ScannedPage page) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text('Page ${page.pageNumber}'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(
                  page.imageData,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(scanSessionProvider.notifier).removePage(page.id);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/scanner/preview?pageId=${page.id}');
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Re-Edit'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(scanSessionProvider.notifier).duplicatePage(page.id);
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Duplicate'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _replacePage(context, ref, page);
                      },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Replace'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ScannedPage page) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Page'),
        content: Text('Delete page ${page.pageNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(scanSessionProvider.notifier).removePage(page.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _replacePage(
    BuildContext context,
    WidgetRef ref,
    ScannedPage page,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    await ref.read(scanSessionProvider.notifier).replacePageImage(page.id, bytes);

    if (!context.mounted) {
      return;
    }

    messenger.showSnackBar(
      SnackBar(content: Text('Replaced page ${page.pageNumber}')),
    );
  }
}

class _PageListItem extends StatelessWidget {
  final ScannedPage page;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onReplace;

  const _PageListItem({
    required Key key,
    required this.page,
    required this.onTap,
    required this.onEdit,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onDelete,
    required this.onDuplicate,
    required this.onReplace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Reorder handle
              const Icon(Icons.drag_handle),
              const SizedBox(width: 8),

              // Page thumbnail
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.memory(
                    page.imageData,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Page info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Page ${page.pageNumber}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      page.isProcessed ? 'Enhanced' : 'Original',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _formatDateTime(page.capturedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: [
                        ActionChip(
                          label: const Text('Edit'),
                          onPressed: onEdit,
                        ),
                        ActionChip(
                          label: const Text('Rotate L'),
                          onPressed: onRotateLeft,
                        ),
                        ActionChip(
                          label: const Text('Rotate R'),
                          onPressed: onRotateRight,
                        ),
                        ActionChip(
                          label: const Text('Duplicate'),
                          onPressed: onDuplicate,
                        ),
                        ActionChip(
                          label: const Text('Replace'),
                          onPressed: onReplace,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
