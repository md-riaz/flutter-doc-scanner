import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/pdf_generation_provider.dart';
import '../../../scanner/presentation/providers/scan_session_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class PdfGenerationScreen extends ConsumerStatefulWidget {
  const PdfGenerationScreen({super.key});

  @override
  ConsumerState<PdfGenerationScreen> createState() =>
      _PdfGenerationScreenState();
}

class _PdfGenerationScreenState extends ConsumerState<PdfGenerationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pdfState = ref.watch(pdfGenerationProvider);
    final sessionState = ref.watch(scanSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate PDF'),
      ),
      body: pdfState.isGenerating
          ? _buildGeneratingView(pdfState.progress ?? 0.0)
          : pdfState.document != null
              ? _buildSuccessView(pdfState.document!)
              : _buildFormView(sessionState.session?.pages.length ?? 0),
    );
  }

  Widget _buildFormView(int pageCount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Creating PDF with $pageCount pages',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Document Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              value: _selectedCategory,
              items: _getCategories()
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Tags field
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma-separated)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
                hintText: 'e.g., invoice, receipt, contract',
              ),
            ),
            const SizedBox(height: 24),

            // Generate button
            ElevatedButton.icon(
              onPressed: _generatePdf,
              icon: const Icon(Icons.check),
              label: const Text('Generate PDF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratingView(double progress) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Generating PDF...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: progress,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(PdfDocument document) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 24),
            Text(
              'PDF Generated Successfully!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Title', document.title),
                    const Divider(),
                    _buildInfoRow('Pages', '${document.pageCount}'),
                    const Divider(),
                    _buildInfoRow('Size', document.fileSizeFormatted),
                    if (document.category != null) ...[
                      const Divider(),
                      _buildInfoRow('Category', document.category!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sharePdf(document),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openPdf(document),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Clear session and go to home
                ref.read(scanSessionProvider.notifier).clearSession();
                ref.read(pdfGenerationProvider.notifier).reset();
                context.go('/');
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(value),
        ],
      ),
    );
  }

  List<String> _getCategories() {
    return [
      'Invoice',
      'Receipt',
      'Contract',
      'Report',
      'Letter',
      'ID Document',
      'Other',
    ];
  }

  Future<void> _generatePdf() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final session = ref.read(scanSessionProvider).session;
    if (session == null || session.pages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pages to generate PDF')),
      );
      return;
    }

    // Parse tags
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final document = await ref.read(pdfGenerationProvider.notifier).generateFromSession(
          session,
          title: _titleController.text.trim(),
          category: _selectedCategory,
          tags: tags,
        );

    if (document == null && mounted) {
      final error = ref.read(pdfGenerationProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $error')),
      );
    }
  }

  Future<void> _openPdf(PdfDocument document) async {
    try {
      await OpenFilex.open(document.filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open PDF: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sharePdf(PdfDocument document) async {
    try {
      await Share.shareXFiles(
        [XFile(document.filePath)],
        subject: document.title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share PDF: ${e.toString()}')),
        );
      }
    }
  }
}
