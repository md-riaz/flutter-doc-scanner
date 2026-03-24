import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/documents_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../pdf/domain/entities/pdf_document.dart';
import '../../../scanner/presentation/providers/scan_session_provider.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  final String? projectId;
  final String? projectName;

  const DocumentsScreen({
    super.key,
    this.projectId,
    this.projectName,
  });

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load documents with project filter if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.projectId != null) {
        ref.read(documentsProvider.notifier).loadDocumentsByProject(widget.projectId!);
      } else {
        ref.read(documentsProvider.notifier).loadDocuments();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentsState = ref.watch(documentsProvider);
    final authState = ref.watch(authStateProvider);
    final isViewer = authState.user?.isViewer ?? false;
    final visibleDocuments = documentsState.filteredDocuments;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName != null
            ? '${widget.projectName} Documents'
            : 'My Documents'),
        actions: [
          if (widget.projectId != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                context.go('/documents');
              },
              tooltip: 'Clear filter',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (widget.projectId != null) {
                ref.read(documentsProvider.notifier).loadDocumentsByProject(widget.projectId!);
              } else {
                ref.read(documentsProvider.notifier).refresh();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                          ref.read(documentsProvider.notifier).searchDocuments('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
                ref.read(documentsProvider.notifier).searchDocuments(value);
              },
            ),
          ),

          // Documents list
          Expanded(
            child: documentsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                    : documentsState.error != null
                        ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(documentsState.error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(documentsProvider.notifier).refresh();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : visibleDocuments.isEmpty
                        ? _buildEmptyState()
                        : _buildDocumentsList(
                            visibleDocuments,
                            isViewer: isViewer,
                          ),
          ),
        ],
      ),
      floatingActionButton: isViewer
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                ref.read(scanSessionProvider.notifier).startSession();
                context.push('/scanner/camera');
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan'),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Documents',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Scan a document to get started',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(
    List<PdfDocument> documents, {
    required bool isViewer,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return _DocumentCard(
          document: doc,
          onTap: () => _openDocument(doc),
          onShare: () => _shareDocument(doc),
          onEdit: isViewer ? null : () => _showEditDialog(doc),
          onDelete: () => _confirmDelete(doc),
          isViewer: isViewer,
        );
      },
    );
  }

  Future<void> _showEditDialog(PdfDocument document) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: document.title);
    final tagsController = TextEditingController(
      text: document.tags.join(', '),
    );
    String? selectedCategory = document.category;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogBuilderContext, setState) => AlertDialog(
          title: const Text('Edit Document'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('No Category'),
                      ),
                      ..._categories.map(
                        (category) => DropdownMenuItem<String?>(
                          value: category,
                          child: Text(category),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags',
                      hintText: 'Comma-separated tags',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final tags = tagsController.text
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();

                try {
                  await ref.read(documentsProvider.notifier).updateDocumentMetadata(
                        id: document.id,
                        title: titleController.text.trim(),
                        category: selectedCategory,
                        tags: tags,
                      );

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update document metadata'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _categories = [
    'Invoice',
    'Receipt',
    'Contract',
    'Report',
    'Letter',
    'ID Document',
    'Other',
  ];

  Future<void> _openDocument(PdfDocument document) async {
    try {
      await OpenFilex.open(document.filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open document: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _shareDocument(PdfDocument document) async {
    try {
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(document.filePath)],
        subject: document.title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share document: ${e.toString()}')),
        );
      }
    }
  }

  void _confirmDelete(PdfDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Delete "${document.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(documentsProvider.notifier).deleteDocument(document.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final PdfDocument document;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;
  final bool isViewer;

  const _DocumentCard({
    required this.document,
    required this.onTap,
    required this.onShare,
    required this.onEdit,
    required this.onDelete,
    required this.isViewer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // PDF icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              // Document info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${document.pageCount} pages • ${document.fileSizeFormatted}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (document.category != null) ...[
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          document.category!,
                          style: const TextStyle(fontSize: 12),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'open',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_new),
                        SizedBox(width: 8),
                        Text('Open'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                  if (!isViewer)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                  if (!isViewer)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'open':
                      onTap();
                      break;
                    case 'share':
                      onShare();
                      break;
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
