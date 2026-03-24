import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/scan_session_provider.dart';
import '../../domain/entities/scan_session.dart';
import '../../domain/entities/scanned_page.dart';
import '../../data/services/image_filters_service.dart';

class PagePreviewScreen extends ConsumerStatefulWidget {
  final String? pageId;

  const PagePreviewScreen({
    super.key,
    this.pageId,
  });

  @override
  ConsumerState<PagePreviewScreen> createState() => _PagePreviewScreenState();
}

class _PagePreviewScreenState extends ConsumerState<PagePreviewScreen> {
  bool _autoEnhance = true;
  ImageFilter _selectedFilter = ImageFilter.none;
  Uint8List? _filteredImageData;
  bool _isApplyingFilter = false;
  final Map<ImageFilter, Uint8List?> _previewCache = {
    ImageFilter.none: null,
  };

  bool get _isEditingExistingPage => widget.pageId != null;

  void _resetPreviewState() {
    setState(() {
      _selectedFilter = ImageFilter.none;
      _filteredImageData = null;
      _previewCache
        ..clear()
        ..[ImageFilter.none] = null;
    });
  }

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

    final page = _resolvePage(session);
    if (page == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/scanner/review');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final displayImage = _filteredImageData ?? page.imageData;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(_isEditingExistingPage
            ? 'Edit Page ${page.pageNumber}'
            : 'Page ${page.pageNumber}'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.push('/scanner/corner-adjustment/${page.id}');
              if (mounted) {
                _resetPreviewState();
              }
            },
            icon: const Icon(Icons.crop_free),
            tooltip: 'Adjust Corners',
          ),
          IconButton(
            onPressed: sessionState.isLoading
                ? null
                : () async {
                    await ref
                        .read(scanSessionProvider.notifier)
                        .rotatePage(page.id, -90);
                    if (mounted) {
                      _resetPreviewState();
                    }
                  },
            icon: const Icon(Icons.rotate_left),
            tooltip: 'Rotate Left',
          ),
          IconButton(
            onPressed: sessionState.isLoading
                ? null
                : () async {
                    await ref
                        .read(scanSessionProvider.notifier)
                        .rotatePage(page.id, 90);
                    if (mounted) {
                      _resetPreviewState();
                    }
                  },
            icon: const Icon(Icons.rotate_right),
            tooltip: 'Rotate Right',
          ),
          if (!_isEditingExistingPage)
            IconButton(
              onPressed: () {
                ref.read(scanSessionProvider.notifier).removePage(page.id);
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
                color: Colors.grey[900]?.withValues(alpha: 0.9),
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
                                    page.imageData,
                                    fit: BoxFit.cover,
                                  ),
                                  if (isSelected)
                                    Container(
                                      color: Colors.blue.withValues(alpha: 0.3),
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
                          _isEditingExistingPage
                              ? context.pop()
                              : _processAndContinue();
                        },
                        icon: Icon(
                          _isEditingExistingPage ? Icons.close : Icons.add,
                        ),
                        label: Text(
                          _isEditingExistingPage
                              ? 'Cancel'
                              : 'Add More Pages',
                        ),
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
                          _isEditingExistingPage
                              ? _saveEditsAndReturn()
                              : _processAndFinish();
                        },
                        icon: const Icon(Icons.check),
                        label: Text(
                          _isEditingExistingPage ? 'Save Changes' : 'Done',
                        ),
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
    setState(() {
      _isApplyingFilter = true;
    });

    try {
      final pageId = ref.read(scanSessionProvider).session!.pages.last.id;

      await _applySelectedFilterToPage(pageId);

      final updatedPage = ref.read(scanSessionProvider).session!.pages
          .firstWhere((page) => page.id == pageId);
      if (!updatedPage.isProcessed || _autoEnhance) {
        await ref.read(scanSessionProvider.notifier).processPage(
              pageId,
              autoEnhance: _autoEnhance,
            );
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save page: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingFilter = false;
        });
      }
    }
  }

  Future<void> _processAndFinish() async {
    setState(() {
      _isApplyingFilter = true;
    });

    try {
      final pageId = ref.read(scanSessionProvider).session!.pages.last.id;

      await _applySelectedFilterToPage(pageId);

      final updatedPage = ref.read(scanSessionProvider).session!.pages
          .firstWhere((page) => page.id == pageId);
      if (!updatedPage.isProcessed || _autoEnhance) {
        await ref.read(scanSessionProvider.notifier).processPage(
              pageId,
              autoEnhance: _autoEnhance,
            );
      }

      if (mounted) {
        context.go('/scanner/review');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to finish page: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingFilter = false;
        });
      }
    }
  }

  Future<void> _saveEditsAndReturn() async {
    setState(() {
      _isApplyingFilter = true;
    });

    try {
      final pageId = widget.pageId!;
      await _applySelectedFilterToPage(pageId);

      final updatedPage = ref.read(scanSessionProvider).session!.pages
          .firstWhere((page) => page.id == pageId);
      if (!updatedPage.isProcessed || _autoEnhance) {
        await ref.read(scanSessionProvider.notifier).processPage(
              pageId,
              autoEnhance: _autoEnhance,
            );
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save changes: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingFilter = false;
        });
      }
    }
  }

  Future<void> _applySelectedFilterToPage(String pageId) async {
    if (_selectedFilter == ImageFilter.none) {
      return;
    }

    final currentPage = ref.read(scanSessionProvider).session!.pages
        .firstWhere((page) => page.id == pageId);
    final filterService = ref.read(imageFiltersServiceProvider);
    final finalFiltered = await filterService.applyFilter(
      currentPage.imageData,
      _selectedFilter,
    );

    await ref.read(scanSessionProvider.notifier).updatePageImage(
          pageId,
          finalFiltered,
        );
  }

  Future<void> _applyFilter(ImageFilter filter) async {
    if (_isApplyingFilter) return;

    if (_previewCache.containsKey(filter)) {
      setState(() {
        _selectedFilter = filter;
        _filteredImageData = _previewCache[filter];
      });
      return;
    }

    setState(() {
      _selectedFilter = filter;
      _isApplyingFilter = true;
    });

    try {
      final sessionState = ref.read(scanSessionProvider);
      final page = _resolvePage(sessionState.session!);
      if (page == null) {
        throw Exception('Page not found');
      }

      if (filter == ImageFilter.none) {
        setState(() {
          _filteredImageData = null;
          _isApplyingFilter = false;
        });
        return;
      }

      final filterService = ref.read(imageFiltersServiceProvider);
      final filtered = await filterService.applyPreviewFilter(
        page.imageData,
        filter,
      );

      if (mounted) {
        setState(() {
          _previewCache[filter] = filtered;
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

  ScannedPage? _resolvePage(ScanSession session) {
    if (widget.pageId == null) {
      return session.pages.last;
    }

    final index = session.pages.indexWhere((page) => page.id == widget.pageId);
    if (index == -1) {
      return null;
    }
    return session.pages[index];
  }
}
