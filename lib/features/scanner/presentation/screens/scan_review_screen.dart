import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doc_scanner/features/scanner/presentation/providers/scan_session_provider.dart';
import 'package:doc_scanner/features/scanner/data/services/image_processing_service.dart';
import 'package:doc_scanner/features/scanner/domain/entities/scanned_page.dart';

class ScanReviewScreen extends ConsumerStatefulWidget {
  const ScanReviewScreen({super.key});

  @override
  ConsumerState<ScanReviewScreen> createState() => _ScanReviewScreenState();
}

class _ScanReviewScreenState extends ConsumerState<ScanReviewScreen> {
  final Set<String> _selectedPageIds = <String>{};
  final Map<String, ScanQualityAssessment> _qualityByPageId = {};
  final Set<String> _qualityPending = <String>{};

  bool get _isSelectionMode => _selectedPageIds.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(scanSessionProvider);
    final session = sessionState.session;

    if (session == null || session.pages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    _selectedPageIds.removeWhere(
      (pageId) => session.pages.every((page) => page.id != pageId),
    );
    _qualityByPageId.removeWhere(
      (pageId, _) => session.pages.every((page) => page.id != pageId),
    );
    _scheduleQualityAnalysis(session.pages);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelectionMode
              ? '${_selectedPageIds.length} Selected'
              : '${session.pages.length} Pages',
        ),
        leading: _isSelectionMode
            ? IconButton(
                onPressed: _clearSelection,
                icon: const Icon(Icons.close),
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              onPressed: session.pages.length == _selectedPageIds.length
                  ? _clearSelection
                  : () => _selectAll(session.pages),
              icon: Icon(
                session.pages.length == _selectedPageIds.length
                    ? Icons.deselect
                    : Icons.select_all,
              ),
              tooltip: session.pages.length == _selectedPageIds.length
                  ? 'Clear Selection'
                  : 'Select All',
            ),
            IconButton(
              onPressed: () => _duplicateSelected(ref),
              icon: const Icon(Icons.copy_all),
              tooltip: 'Duplicate Selected',
            ),
            IconButton(
              onPressed: () => _deleteSelected(ref),
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Delete Selected',
            ),
          ] else
            IconButton(
              onPressed: () {
                context.push('/scanner/camera');
              },
              icon: const Icon(Icons.add_a_photo),
              tooltip: 'Add Pages',
            ),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: session.pages.length,
        onReorder: _isSelectionMode
            ? (_, __) {}
            : (oldIndex, newIndex) {
                ref.read(scanSessionProvider.notifier).reorderPages(
                      oldIndex,
                      newIndex,
                    );
              },
        itemBuilder: (context, index) {
          final page = session.pages[index];
          final isSelected = _selectedPageIds.contains(page.id);

          return _PageListItem(
            key: ValueKey(page.id),
            page: page,
            isSelectionMode: _isSelectionMode,
            isSelected: isSelected,
            onTap: () {
              if (_isSelectionMode) {
                _toggleSelection(page.id);
                return;
              }
              _showPageDetail(context, ref, page);
            },
            onLongPress: () => _toggleSelection(page.id),
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
            onSelected: (selected) {
              if (selected) {
                _toggleSelection(page.id, forceSelect: true);
              } else {
                _toggleSelection(page.id, forceSelect: false);
              }
            },
            qualityAssessment: _qualityByPageId[page.id],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: sessionState.isLoading || _isSelectionMode
              ? null
              : () {
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

  void _toggleSelection(String pageId, {bool? forceSelect}) {
    setState(() {
      if (forceSelect == true) {
        _selectedPageIds.add(pageId);
      } else if (forceSelect == false) {
        _selectedPageIds.remove(pageId);
      } else if (_selectedPageIds.contains(pageId)) {
        _selectedPageIds.remove(pageId);
      } else {
        _selectedPageIds.add(pageId);
      }
    });
  }

  void _selectAll(List<ScannedPage> pages) {
    setState(() {
      _selectedPageIds
        ..clear()
        ..addAll(pages.map((page) => page.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPageIds.clear();
    });
  }

  void _duplicateSelected(WidgetRef ref) {
    ref.read(scanSessionProvider.notifier).duplicatePages(
          _selectedPageIds.toList(),
        );
    _clearSelection();
  }

  void _deleteSelected(WidgetRef ref) {
    ref.read(scanSessionProvider.notifier).removePages(
          _selectedPageIds.toList(),
        );
    _clearSelection();
  }

  void _showPageDetail(BuildContext context, WidgetRef ref, ScannedPage page) {
    final quality = _qualityByPageId[page.id];
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text('Page ${page.pageNumber}'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(dialogContext),
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
              child: Column(
                children: [
                  if (quality != null && quality.hasWarnings)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: quality.warnings
                            .map(
                              (warning) => Chip(
                                label: Text(warning),
                                avatar: const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 18,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(dialogContext);
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
                            Navigator.pop(dialogContext);
                            context.push('/scanner/preview?pageId=${page.id}');
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Re-Edit'),
                        ),
                      ),
                    ],
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
                        Navigator.pop(dialogContext);
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
                        Navigator.pop(dialogContext);
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Page'),
        content: Text('Delete page ${page.pageNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(scanSessionProvider.notifier).removePage(page.id);
              Navigator.pop(dialogContext);
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

  void _scheduleQualityAnalysis(List<ScannedPage> pages) {
    for (final page in pages) {
      if (_qualityByPageId.containsKey(page.id) || _qualityPending.contains(page.id)) {
        continue;
      }

      _qualityPending.add(page.id);
      ref
          .read(imageProcessingServiceProvider)
          .analyzeDocumentQuality(page.imageData)
          .then((assessment) {
        if (!mounted) {
          return;
        }
        setState(() {
          _qualityPending.remove(page.id);
          _qualityByPageId[page.id] = assessment;
        });
      });
    }
  }
}

class _PageListItem extends StatelessWidget {
  final ScannedPage page;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onReplace;
  final ValueChanged<bool> onSelected;
  final ScanQualityAssessment? qualityAssessment;

  const _PageListItem({
    required Key key,
    required this.page,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onDelete,
    required this.onDuplicate,
    required this.onReplace,
    required this.onSelected,
    required this.qualityAssessment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (isSelectionMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => onSelected(value ?? false),
                )
              else ...[
                const Icon(Icons.drag_handle),
                const SizedBox(width: 8),
              ],
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
                    if (qualityAssessment != null) ...[
                      const SizedBox(height: 8),
                      _QualityScoreBadge(score: qualityAssessment!.score),
                    ],
                    if (qualityAssessment != null && qualityAssessment!.hasWarnings) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: qualityAssessment!.warnings
                            .take(2)
                            .map(
                              (warning) => Chip(
                                label: Text(
                                  warning,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (!isSelectionMode) ...[
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
                  ],
                ),
              ),
              if (!isSelectionMode)
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

class _QualityScoreBadge extends StatelessWidget {
  final int score;

  const _QualityScoreBadge({
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (score) {
      >= 85 => Colors.green,
      >= 65 => Colors.orange,
      _ => Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        'Quality $score',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
