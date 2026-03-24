import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/scan_session_provider.dart';
import '../../domain/entities/scan_session.dart';
import '../../domain/entities/scanned_page.dart';
import '../../data/services/image_processing_service.dart';
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
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  double _cleanup = 0.0;
  double _sharpness = 0.0;
  ImageFilter _selectedFilter = ImageFilter.none;
  Uint8List? _filteredImageData;
  bool _isApplyingFilter = false;
  String? _loadedPageId;
  final Map<String, Uint8List?> _previewCache = {};

  bool get _isEditingExistingPage => widget.pageId != null;

  void _resetPreviewState() {
    setState(() {
      _loadedPageId = null;
      _filteredImageData = null;
      _previewCache.clear();
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

    _loadPageState(page);

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
                      onTap: () => _selectFilter(filter),
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
                    _refreshPreview();
                  },
                ),
                _buildSlider(
                  label: 'Brightness',
                  value: _brightness,
                  min: -0.35,
                  max: 0.35,
                  divisions: 14,
                  onChanged: (value) {
                    setState(() {
                      _brightness = value;
                    });
                  },
                  onChangeEnd: (_) => _refreshPreview(),
                ),
                _buildSlider(
                  label: 'Contrast',
                  value: _contrast,
                  min: 0.6,
                  max: 1.6,
                  divisions: 10,
                  onChanged: (value) {
                    setState(() {
                      _contrast = value;
                    });
                  },
                  onChangeEnd: (_) => _refreshPreview(),
                ),
                _buildSlider(
                  label: 'Saturation',
                  value: _saturation,
                  min: 0.0,
                  max: 1.8,
                  divisions: 18,
                  onChanged: (value) {
                    setState(() {
                      _saturation = value;
                    });
                  },
                  onChangeEnd: (_) => _refreshPreview(),
                ),
                _buildSlider(
                  label: 'Cleanup',
                  value: _cleanup,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (value) {
                    setState(() {
                      _cleanup = value;
                    });
                  },
                  onChangeEnd: (_) => _refreshPreview(),
                ),
                _buildSlider(
                  label: 'Sharpness',
                  value: _sharpness,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (value) {
                    setState(() {
                      _sharpness = value;
                    });
                  },
                  onChangeEnd: (_) => _refreshPreview(),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _resetDocumentAdjustments,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset Adjustments'),
                  ),
                ),
                const SizedBox(height: 8),
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
    await _savePage(
      onSuccess: () => context.pop(),
      errorPrefix: 'Failed to save page',
    );
  }

  Future<void> _processAndFinish() async {
    await _savePage(
      onSuccess: () => context.go('/scanner/review'),
      errorPrefix: 'Failed to finish page',
    );
  }

  Future<void> _saveEditsAndReturn() async {
    await _savePage(
      onSuccess: () => context.pop(),
      errorPrefix: 'Failed to save changes',
    );
  }

  Future<void> _selectFilter(ImageFilter filter) async {
    setState(() {
      _selectedFilter = filter;
    });
    await _refreshPreview();
  }

  Future<void> _refreshPreview() async {
    if (_isApplyingFilter) return;

    final signature = _settingsSignature(_currentSettings);
    if (_previewCache.containsKey(signature)) {
      setState(() {
        _filteredImageData = _previewCache[signature];
      });
      return;
    }

    setState(() {
      _isApplyingFilter = true;
    });

    try {
      final sessionState = ref.read(scanSessionProvider);
      final page = _resolvePage(sessionState.session!);
      if (page == null) {
        throw Exception('Page not found');
      }

      final filtered = await ref.read(imageProcessingServiceProvider).applyPreviewDocumentEdits(
        page.originalImageData,
        settings: _currentSettings,
      );

      if (mounted) {
        setState(() {
          _previewCache[signature] = filtered;
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

  Future<void> _savePage({
    required VoidCallback onSuccess,
    required String errorPrefix,
  }) async {
    setState(() {
      _isApplyingFilter = true;
    });

    try {
      final pageId = widget.pageId ?? ref.read(scanSessionProvider).session!.pages.last.id;

      final currentPage = ref.read(scanSessionProvider).session!.pages
          .firstWhere((page) => page.id == pageId);
      if (!currentPage.isProcessed) {
        await ref.read(scanSessionProvider.notifier).processPage(
              pageId,
              autoEnhance: false,
            );
      }

      await ref.read(scanSessionProvider.notifier).applyPageEdits(
            pageId,
            _currentSettings,
          );

      if (!mounted) return;
      onSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$errorPrefix: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingFilter = false;
        });
      }
    }
  }

  void _loadPageState(ScannedPage page) {
    if (_loadedPageId == page.id) {
      return;
    }

    final savedSettings = page.editSettings;
    _loadedPageId = page.id;
    _autoEnhance = savedSettings.autoEnhance;
    _brightness = savedSettings.brightness;
    _contrast = savedSettings.contrast;
    _saturation = savedSettings.saturation;
    _cleanup = savedSettings.cleanup;
    _sharpness = savedSettings.sharpness;
    final filterIndex = savedSettings.filterIndex.clamp(
      0,
      ImageFilter.values.length - 1,
    );
    _selectedFilter = ImageFilter.values[filterIndex];
    _filteredImageData = null;
    _previewCache
      ..clear()
      ..[_settingsSignature(savedSettings)] = page.imageData;
  }

  void _resetDocumentAdjustments() {
    setState(() {
      _autoEnhance = true;
      _brightness = 0.0;
      _contrast = 1.0;
      _saturation = 1.0;
      _cleanup = 0.0;
      _sharpness = 0.0;
      _selectedFilter = ImageFilter.none;
    });
    _refreshPreview();
  }

  ScannedPageEditSettings get _currentSettings => ScannedPageEditSettings(
        brightness: _brightness,
        contrast: _contrast,
        saturation: _saturation,
        cleanup: _cleanup,
        sharpness: _sharpness,
        autoEnhance: _autoEnhance,
        filterIndex: _selectedFilter.index,
      );

  String _settingsSignature(ScannedPageEditSettings settings) {
    return [
      settings.autoEnhance,
      settings.filterIndex,
      settings.brightness.toStringAsFixed(3),
      settings.contrast.toStringAsFixed(3),
      settings.saturation.toStringAsFixed(3),
      settings.cleanup.toStringAsFixed(3),
      settings.sharpness.toStringAsFixed(3),
    ].join('|');
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
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
