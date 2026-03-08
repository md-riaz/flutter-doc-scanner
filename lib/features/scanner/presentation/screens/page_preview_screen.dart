import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/scan_session_provider.dart';
import '../../data/services/image_filters_service.dart';
import '../../data/services/image_processing_service.dart';

class PagePreviewScreen extends ConsumerStatefulWidget {
  const PagePreviewScreen({super.key});

  @override
  ConsumerState<PagePreviewScreen> createState() => _PagePreviewScreenState();
}

class _PagePreviewScreenState extends ConsumerState<PagePreviewScreen> {
  bool _autoEnhance = true;
  ImageFilter _selectedFilter = ImageFilter.none;
  Uint8List? _filteredImageData;
  bool _isApplyingFilter = false;

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
    final displayImage = _filteredImageData ?? lastPage.imageData;

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
              child: sessionState.isLoading || _isApplyingFilter
                  ? const CircularProgressIndicator(color: Colors.white)
                  : InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.memory(
                        displayImage,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ),

          // Filter selector
          if (!sessionState.isLoading && !_isApplyingFilter)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.9),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: ImageFilter.values.length,
                itemBuilder: (context, index) {
                  final filter = ImageFilter.values[index];
                  final filterService = ref.read(imageFiltersServiceProvider);
                  final isSelected = _selectedFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => _applyFilter(filter),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.white30,
                                width: isSelected ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.memory(
                                    lastPage.imageData,
                                    fit: BoxFit.cover,
                                  ),
                                  if (isSelected)
                                    Container(
                                      color: Colors.blue.withOpacity(0.3),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            filterService.getFilterName(filter),
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.white,
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

    // Apply filter if selected
    if (_selectedFilter != ImageFilter.none && _filteredImageData != null) {
      await ref.read(scanSessionProvider.notifier).updatePageImage(
            lastPage.id,
            _filteredImageData!,
          );
    }

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

    // Apply filter if selected
    if (_selectedFilter != ImageFilter.none && _filteredImageData != null) {
      await ref.read(scanSessionProvider.notifier).updatePageImage(
            lastPage.id,
            _filteredImageData!,
          );
    }

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

  Future<void> _applyFilter(ImageFilter filter) async {
    if (_isApplyingFilter) return;

    setState(() {
      _selectedFilter = filter;
      _isApplyingFilter = true;
    });

    try {
      final sessionState = ref.read(scanSessionProvider);
      final lastPage = sessionState.session!.pages.last;

      if (filter == ImageFilter.none) {
        setState(() {
          _filteredImageData = null;
          _isApplyingFilter = false;
        });
        return;
      }

      final filterService = ref.read(imageFiltersServiceProvider);
      final filtered = await filterService.applyFilter(
        lastPage.imageData,
        filter,
      );

      if (mounted) {
        setState(() {
          _filteredImageData = filtered;
          _isApplyingFilter = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isApplyingFilter = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply filter: $e')),
        );
      }
    }
  }
}
