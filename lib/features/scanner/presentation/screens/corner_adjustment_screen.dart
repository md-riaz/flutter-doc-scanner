import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/scan_session_provider.dart';
import '../../data/services/edge_detection_service.dart';
import '../../domain/entities/scanned_page.dart';

class CornerAdjustmentScreen extends ConsumerStatefulWidget {
  final String pageId;

  const CornerAdjustmentScreen({
    super.key,
    required this.pageId,
  });

  @override
  ConsumerState<CornerAdjustmentScreen> createState() =>
      _CornerAdjustmentScreenState();
}

class _CornerAdjustmentScreenState
    extends ConsumerState<CornerAdjustmentScreen> {
  List<Offset>? _corners;
  Size? _imageSize;
  bool _isLoading = true;
  bool _isApplying = false;
  ScannedPage? _page;

  @override
  void initState() {
    super.initState();
    _detectCorners();
  }

  Future<void> _detectCorners() async {
    setState(() => _isLoading = true);

    try {
      final sessionState = ref.read(scanSessionProvider);
      _page = sessionState.session?.pages.firstWhere(
        (p) => p.id == widget.pageId,
      );

      if (_page == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Page not found')),
          );
          context.pop();
        }
        return;
      }

      // Decode image to get dimensions
      final codec = await ui.instantiateImageCodec(_page!.imageData);
      final frame = await codec.getNextFrame();
      _imageSize = Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );

      // Auto-detect corners using OpenCV
      final edgeService = ref.read(edgeDetectionServiceProvider);
      final detectedCorners = await edgeService.detectDocumentEdges(
        _page!.imageData,
        frame.image.width,
        frame.image.height,
      );

      if (mounted) {
        setState(() {
          _corners = detectedCorners ?? _getDefaultCorners();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _corners = _getDefaultCorners();
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detection failed: $e')),
        );
      }
    }
  }

  List<Offset> _getDefaultCorners() {
    if (_imageSize == null) return [];
    const margin = 0.05;
    return [
      Offset(_imageSize!.width * margin, _imageSize!.height * margin),
      Offset(_imageSize!.width * (1 - margin), _imageSize!.height * margin),
      Offset(_imageSize!.width * (1 - margin),
          _imageSize!.height * (1 - margin)),
      Offset(_imageSize!.width * margin, _imageSize!.height * (1 - margin)),
    ];
  }

  void _onCornerDragged(int index, Offset localPosition, Size displaySize) {
    if (_corners == null || _imageSize == null) return;

    // Convert from display coordinates to image coordinates
    final scaleX = _imageSize!.width / displaySize.width;
    final scaleY = _imageSize!.height / displaySize.height;

    final imageX = localPosition.dx * scaleX;
    final imageY = localPosition.dy * scaleY;

    // Clamp to image bounds
    final clampedX = imageX.clamp(0.0, _imageSize!.width);
    final clampedY = imageY.clamp(0.0, _imageSize!.height);

    setState(() {
      _corners![index] = Offset(clampedX, clampedY);
    });
  }

  Future<void> _applyTransformation() async {
    if (_corners == null || _page == null || _corners!.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid corners')),
      );
      return;
    }

    setState(() => _isApplying = true);

    try {
      final edgeService = ref.read(edgeDetectionServiceProvider);
      final transformed = await edgeService.applyPerspectiveTransform(
        _page!.imageData,
        _corners!,
      );

      if (transformed != null && mounted) {
        // Update the page with transformed image
        await ref.read(scanSessionProvider.notifier).updatePageImage(
              widget.pageId,
              transformed,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Corners applied successfully')),
          );
          context.pop();
        }
      } else {
        throw Exception('Transformation failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isApplying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_page == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Adjust Corners'),
        actions: [
          if (!_isLoading && !_isApplying)
            IconButton(
              onPressed: _detectCorners,
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset Detection',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Detecting corners...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Help text
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey[900],
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Drag the corners to adjust document boundaries',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Image with corner overlay
                Expanded(
                  child: Center(
                    child: _isApplying
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Applying transformation...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        : _corners != null && _imageSize != null
                            ? _CornerAdjustmentWidget(
                                imageData: _page!.imageData,
                                corners: _corners!,
                                imageSize: _imageSize!,
                                onCornerDragged: _onCornerDragged,
                              )
                            : const Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.white),
                              ),
                  ),
                ),

                // Action buttons
                if (!_isApplying && _corners != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.all(16),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _applyTransformation,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _CornerAdjustmentWidget extends StatelessWidget {
  final Uint8List imageData;
  final List<Offset> corners;
  final Size imageSize;
  final Function(int index, Offset position, Size displaySize) onCornerDragged;

  const _CornerAdjustmentWidget({
    required this.imageData,
    required this.corners,
    required this.imageSize,
    required this.onCornerDragged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate display size maintaining aspect ratio
        final aspectRatio = imageSize.width / imageSize.height;
        double displayWidth, displayHeight;

        if (constraints.maxWidth / constraints.maxHeight > aspectRatio) {
          displayHeight = constraints.maxHeight;
          displayWidth = displayHeight * aspectRatio;
        } else {
          displayWidth = constraints.maxWidth;
          displayHeight = displayWidth / aspectRatio;
        }

        final displaySize = Size(displayWidth, displayHeight);

        return SizedBox(
          width: displayWidth,
          height: displayHeight,
          child: Stack(
            children: [
              // Image
              Image.memory(
                imageData,
                width: displayWidth,
                height: displayHeight,
                fit: BoxFit.contain,
              ),

              // Corner overlay with lines
              CustomPaint(
                size: displaySize,
                painter: _CornerOverlayPainter(
                  corners: corners,
                  imageSize: imageSize,
                  displaySize: displaySize,
                ),
              ),

              // Draggable corner points
              ...List.generate(
                4,
                (index) => _DraggableCorner(
                  index: index,
                  corner: corners[index],
                  imageSize: imageSize,
                  displaySize: displaySize,
                  onDragged: (position) =>
                      onCornerDragged(index, position, displaySize),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DraggableCorner extends StatefulWidget {
  final int index;
  final Offset corner;
  final Size imageSize;
  final Size displaySize;
  final Function(Offset position) onDragged;

  const _DraggableCorner({
    required this.index,
    required this.corner,
    required this.imageSize,
    required this.displaySize,
    required this.onDragged,
  });

  @override
  State<_DraggableCorner> createState() => _DraggableCornerState();
}

class _DraggableCornerState extends State<_DraggableCorner> {
  bool _isDragging = false;

  Offset _getDisplayPosition() {
    final scaleX = widget.displaySize.width / widget.imageSize.width;
    final scaleY = widget.displaySize.height / widget.imageSize.height;
    return Offset(
      widget.corner.dx * scaleX,
      widget.corner.dy * scaleY,
    );
  }

  String _getCornerLabel() {
    switch (widget.index) {
      case 0:
        return 'TL';
      case 1:
        return 'TR';
      case 2:
        return 'BR';
      case 3:
        return 'BL';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayPos = _getDisplayPosition();

    return Positioned(
      left: displayPos.dx - 20,
      top: displayPos.dy - 20,
      child: GestureDetector(
        onPanStart: (_) {
          setState(() => _isDragging = true);
        },
        onPanUpdate: (details) {
          final localX = displayPos.dx + details.delta.dx;
          final localY = displayPos.dy + details.delta.dy;
          widget.onDragged(Offset(localX, localY));
        },
        onPanEnd: (_) {
          setState(() => _isDragging = false);
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isDragging
                ? Colors.blue.withOpacity(0.8)
                : Colors.blue.withOpacity(0.6),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getCornerLabel(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CornerOverlayPainter extends CustomPainter {
  final List<Offset> corners;
  final Size imageSize;
  final Size displaySize;

  _CornerOverlayPainter({
    required this.corners,
    required this.imageSize,
    required this.displaySize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.length != 4) return;

    // Convert corners from image coordinates to display coordinates
    final scaleX = displaySize.width / imageSize.width;
    final scaleY = displaySize.height / imageSize.height;

    final displayCorners = corners.map((corner) {
      return Offset(corner.dx * scaleX, corner.dy * scaleY);
    }).toList();

    // Draw semi-transparent overlay outside the quadrilateral
    final path = Path()
      ..moveTo(displayCorners[0].dx, displayCorners[0].dy)
      ..lineTo(displayCorners[1].dx, displayCorners[1].dy)
      ..lineTo(displayCorners[2].dx, displayCorners[2].dy)
      ..lineTo(displayCorners[3].dx, displayCorners[3].dy)
      ..close();

    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, displaySize.width, displaySize.height))
      ..addPath(path, Offset.zero)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withOpacity(0.5),
    );

    // Draw quadrilateral border
    final borderPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, borderPaint);

    // Draw lines connecting corners
    final linePaint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..strokeWidth = 2;

    for (int i = 0; i < 4; i++) {
      final start = displayCorners[i];
      final end = displayCorners[(i + 1) % 4];
      canvas.drawLine(start, end, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CornerOverlayPainter oldDelegate) {
    return corners != oldDelegate.corners ||
        imageSize != oldDelegate.imageSize ||
        displaySize != oldDelegate.displaySize;
  }
}
