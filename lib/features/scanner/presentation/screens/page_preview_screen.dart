import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/scan_session_provider.dart';

class PagePreviewScreen extends ConsumerStatefulWidget {
  const PagePreviewScreen({super.key});

  @override
  ConsumerState<PagePreviewScreen> createState() => _PagePreviewScreenState();
}

class _PagePreviewScreenState extends ConsumerState<PagePreviewScreen> {
  bool _autoEnhance = true;

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(scanSessionProvider);
    final session = sessionState.session;

    if (session == null || session.pages.isEmpty) {
      // Redirect back if no pages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pop();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final lastPage = session.pages.last;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Page ${lastPage.pageNumber}'),
        actions: [
          IconButton(
            onPressed: () {
              // Retake - remove the page and go back
              ref.read(scanSessionProvider.notifier).removePage(lastPage.id);
              context.pop();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Retake',
          ),
        ],
      ),
      body: Column(
        children: [
          // Image preview
          Expanded(
            child: Center(
              child: sessionState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.memory(
                        lastPage.imageData,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ),

          // Enhancement controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Auto-Enhance',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Optimize brightness, contrast, and sharpness',
                    style: TextStyle(color: Colors.grey),
                  ),
                  value: _autoEnhance,
                  onChanged: (value) {
                    setState(() {
                      _autoEnhance = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Apply processing and add another page
                          _processAndContinue();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add More Pages'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Apply processing and finish
                          _processAndFinish();
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Done'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processAndContinue() async {
    final sessionState = ref.read(scanSessionProvider);
    final lastPage = sessionState.session!.pages.last;

    // Process the page if needed
    if (_autoEnhance && !lastPage.isProcessed) {
      await ref.read(scanSessionProvider.notifier).processPage(
            lastPage.id,
            autoEnhance: _autoEnhance,
          );
    }

    if (mounted) {
      // Go back to camera to add more pages
      context.pop();
    }
  }

  Future<void> _processAndFinish() async {
    final sessionState = ref.read(scanSessionProvider);
    final lastPage = sessionState.session!.pages.last;

    // Process the page if needed
    if (_autoEnhance && !lastPage.isProcessed) {
      await ref.read(scanSessionProvider.notifier).processPage(
            lastPage.id,
            autoEnhance: _autoEnhance,
          );
    }

    if (mounted) {
      // Navigate to review screen
      context.go('/scanner/review');
    }
  }
}
