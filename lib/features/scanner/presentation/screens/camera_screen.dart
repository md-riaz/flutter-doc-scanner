import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/scan_session_provider.dart';
import '../../data/services/camera_service.dart';
import '../../data/services/edge_detection_service.dart';
import 'package:go_router/go_router.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  bool _isFlashOn = false;
  int _tipIndex = 0;
  bool _isProcessingLiveFrame = false;
  DateTime? _lastLiveDetectionAt;
  List<Offset>? _liveDetectedCorners;

  static const List<String> _scanTips = [
    'Keep the page flat inside the frame',
    'Avoid shadows across the document',
    'Use even lighting for sharper text',
    'Hold steady before tapping capture',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(cameraServiceProvider).stopImageStream();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(cameraServiceProvider).controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      ref.read(cameraServiceProvider).dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final scanSession = ref.read(scanSessionProvider);
    if (scanSession.session == null) {
      ref.read(scanSessionProvider.notifier).startSession();
    }
    await ref.read(scanSessionProvider.notifier).initializeCamera();
    await _startLiveDetection();
  }

  Future<void> _captureImage() async {
    await ref.read(cameraServiceProvider).stopImageStream();
    final scanSession = ref.read(scanSessionProvider.notifier);
    await scanSession.capturePage();

    if (mounted) {
      final session = ref.read(scanSessionProvider).session;
      if (session != null && session.pages.isNotEmpty) {
        if (!context.mounted) return;
        await context.push('/scanner/preview');
        if (mounted) {
          await _startLiveDetection();
        }
      }
    }
  }

  Future<void> _toggleFlash() async {
    final cameraService = ref.read(cameraServiceProvider);
    final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
    await cameraService.setFlashMode(newMode);
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  Future<void> _importFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null && mounted) {
        await ref.read(cameraServiceProvider).stopImageStream();
        // Add the image to the scan session
        final scanSession = ref.read(scanSessionProvider.notifier);
        final File imageFile = File(image.path);
        final bytes = await imageFile.readAsBytes();

        await scanSession.addImageFromGallery(bytes);

        if (!context.mounted) return;

        // Navigate to preview screen
        await context.push('/scanner/preview');
        if (mounted) {
          await _startLiveDetection();
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(scanSessionProvider);
    final cameraService = ref.watch(cameraServiceProvider);
    final controller = cameraService.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Document'),
        actions: [
          if (sessionState.session != null &&
              sessionState.session!.pages.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                await ref.read(cameraServiceProvider).stopImageStream();
                if (!context.mounted) return;
                await context.push('/scanner/review');
                if (mounted) {
                  await _startLiveDetection();
                }
              },
              icon: const Icon(Icons.photo_library, color: Colors.white),
              label: Text(
                '${sessionState.session!.pages.length}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: sessionState.isLoading && !sessionState.isCameraInitialized
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Initializing camera...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : sessionState.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          sessionState.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _initializeCamera,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : controller != null && controller.value.isInitialized
                  ? _buildCameraView(controller)
                  : const Center(
                      child: Text(
                        'Camera not available',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
    );
  }

  Widget _buildCameraView(CameraController controller) {
    final sessionState = ref.watch(scanSessionProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: _buildFullScreenPreview(controller),
        ),

        // Controls overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Flash toggle
                IconButton(
                  onPressed: _toggleFlash,
                  icon: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                // Capture button
                GestureDetector(
                  onTap: sessionState.isLoading ? null : _captureImage,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: sessionState.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(
                            Icons.camera,
                            color: Colors.black,
                            size: 36,
                          ),
                  ),
                ),

                // Gallery button
                IconButton(
                  onPressed: _importFromGallery,
                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Hint text
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _liveDetectedCorners == null
                  ? _scanTips[_tipIndex]
                  : 'Document detected. Adjust position and capture.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: FilledButton.tonalIcon(
            onPressed: () {
              setState(() {
                _tipIndex = (_tipIndex + 1) % _scanTips.length;
              });
            },
            icon: const Icon(Icons.tips_and_updates),
            label: const Text('Tips'),
          ),
        ),
      ],
    );
  }

  Widget _buildFullScreenPreview(CameraController controller) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller);
    }

    final orientation = MediaQuery.orientationOf(context);
    final previewWidth = orientation == Orientation.portrait
        ? previewSize.height
        : previewSize.width;
    final previewHeight = orientation == Orientation.portrait
        ? previewSize.width
        : previewSize.height;

    return ClipRect(
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewWidth,
            height: previewHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(controller),
                CustomPaint(
                  painter: LiveDocumentOverlayPainter(
                    corners: _liveDetectedCorners,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startLiveDetection() async {
    final cameraService = ref.read(cameraServiceProvider);
    if (!cameraService.isInitialized || cameraService.isStreamingImages) {
      return;
    }

    try {
      await cameraService.startImageStream(_handleLiveFrame);
    } catch (_) {
      // Fallback to static guidance if image streaming is unavailable.
    }
  }

  Future<void> _handleLiveFrame(CameraImage image) async {
    final now = DateTime.now();
    if (_isProcessingLiveFrame) {
      return;
    }
    if (_lastLiveDetectionAt != null &&
        now.difference(_lastLiveDetectionAt!).inMilliseconds < 700) {
      return;
    }

    _isProcessingLiveFrame = true;
    _lastLiveDetectionAt = now;

    try {
      final frame = ref.read(cameraServiceProvider).buildLiveDetectionFrame(image);
      if (frame == null) {
        return;
      }

      final corners = await ref.read(edgeDetectionServiceProvider).detectDocumentEdges(
            frame.jpegBytes,
            frame.width,
            frame.height,
          );

      if (!mounted) {
        return;
      }

      final usableCorners = corners == null || corners.length != 4
          ? null
          : _isFallbackRectangle(corners, frame.width, frame.height)
              ? null
              : corners;

      setState(() {
        _liveDetectedCorners = usableCorners == null
            ? null
            : usableCorners
                .map(
                  (corner) => _mapDetectionPointToPreview(
                    corner,
                    frame.width,
                    frame.height,
                  ),
                )
                .toList();
      });
    } catch (_) {
      // Ignore intermittent detection errors during preview streaming.
    } finally {
      _isProcessingLiveFrame = false;
    }
  }

  bool _isFallbackRectangle(
    List<Offset> corners,
    int width,
    int height,
  ) {
    const marginRatio = 0.05;
    const tolerance = 18.0;

    final expected = [
      Offset(width * marginRatio, height * marginRatio),
      Offset(width * (1 - marginRatio), height * marginRatio),
      Offset(width * (1 - marginRatio), height * (1 - marginRatio)),
      Offset(width * marginRatio, height * (1 - marginRatio)),
    ];

    for (var i = 0; i < 4; i++) {
      final dx = (corners[i].dx - expected[i].dx).abs();
      final dy = (corners[i].dy - expected[i].dy).abs();
      if (dx > tolerance || dy > tolerance) {
        return false;
      }
    }

    return true;
  }

  Offset _mapDetectionPointToPreview(
    Offset point,
    int frameWidth,
    int frameHeight,
  ) {
    final normalized = Offset(
      point.dx / frameWidth,
      point.dy / frameHeight,
    );

    final camera = ref.read(cameraServiceProvider).controller;
    final description = camera?.description;
    if (description == null) {
      return normalized;
    }

    final sensorOrientation = description.sensorOrientation % 360;
    final rotated = switch (sensorOrientation) {
      90 => Offset(1 - normalized.dy, normalized.dx),
      180 => Offset(1 - normalized.dx, 1 - normalized.dy),
      270 => Offset(normalized.dy, 1 - normalized.dx),
      _ => normalized,
    };

    if (description.lensDirection == CameraLensDirection.front) {
      return Offset(1 - rotated.dx, rotated.dy);
    }

    return rotated;
  }
}

/// Draws the detected document polygon over the live preview.
class LiveDocumentOverlayPainter extends CustomPainter {
  final List<Offset>? corners;

  LiveDocumentOverlayPainter({
    required this.corners,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final margin = 32.0;
    final defaultRect = Rect.fromLTRB(
      margin,
      margin,
      size.width - margin,
      size.height - margin,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(defaultRect, const Radius.circular(20)),
      guidePaint,
    );

    if (corners?.length != 4) {
      return;
    }

    final points = corners!
        .map((corner) => Offset(corner.dx * size.width, corner.dy * size.height))
        .toList();

    final polygon = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..lineTo(points[1].dx, points[1].dy)
      ..lineTo(points[2].dx, points[2].dy)
      ..lineTo(points[3].dx, points[3].dy)
      ..close();

    canvas.drawPath(
      polygon,
      Paint()
        ..color = Colors.greenAccent.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    for (final point in points) {
      canvas.drawCircle(
        point,
        6,
        Paint()..color = Colors.greenAccent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LiveDocumentOverlayPainter oldDelegate) {
    return corners != oldDelegate.corners;
  }
}
