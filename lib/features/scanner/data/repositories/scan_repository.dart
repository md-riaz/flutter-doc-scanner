import 'dart:typed_data';
import 'dart:ui' as ui show Offset, instantiateImageCodec;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doc_scanner/features/scanner/domain/entities/scanned_page.dart';
import 'package:doc_scanner/features/scanner/domain/entities/scan_session.dart';
import 'package:doc_scanner/features/scanner/data/services/camera_service.dart';
import 'package:doc_scanner/features/scanner/data/services/image_processing_service.dart';
import 'package:uuid/uuid.dart';

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  final cameraService = ref.watch(cameraServiceProvider);
  final imageProcessingService = ref.watch(imageProcessingServiceProvider);
  return ScanRepository(cameraService, imageProcessingService);
});

/// Repository for managing scan sessions and pages
class ScanRepository {
  final CameraService _cameraService;
  final ImageProcessingService _imageProcessingService;
  final _uuid = const Uuid();

  ScanRepository(this._cameraService, this._imageProcessingService);

  /// Create a new scan session
  ScanSession createSession({String? projectId, String? title}) {
    return ScanSession(
      id: _uuid.v4(),
      pages: [],
      createdAt: DateTime.now(),
      projectId: projectId,
      title: title,
    );
  }

  /// Capture an image and add it to the session
  Future<ScannedPage> capturePage(int pageNumber) async {
    final image = await _cameraService.captureImage();
    final imageData = await image.readAsBytes();

    return ScannedPage(
      id: _uuid.v4(),
      imageData: imageData,
      capturedAt: DateTime.now(),
      pageNumber: pageNumber,
      isProcessed: false,
    );
  }

  /// Create a scanned page from image bytes (for gallery import)
  Future<ScannedPage> createPageFromBytes(
    List<int> imageBytes,
    int pageNumber,
  ) async {
    return ScannedPage(
      id: _uuid.v4(),
      imageData: Uint8List.fromList(imageBytes),
      capturedAt: DateTime.now(),
      pageNumber: pageNumber,
      isProcessed: false,
    );
  }

  /// Process a scanned page (crop, enhance)
  Future<ScannedPage> processPage(
    ScannedPage page, {
    List<ui.Offset>? corners,
    bool autoEnhance = false,
  }) async {
    var processedData = page.imageData;
    List<ui.Offset>? detectedCorners = corners;

    detectedCorners ??= await _detectDocumentCorners(processedData);

    // Apply perspective correction when document bounds are available.
    if (detectedCorners != null && detectedCorners.length == 4) {
      final transformed = await _imageProcessingService.applyPerspectiveTransform(
        processedData,
        detectedCorners,
      );

      if (transformed != null) {
        processedData = transformed;
      }
    }

    // Auto-enhance
    if (autoEnhance) {
      processedData = await _imageProcessingService.autoEnhanceDocument(
        processedData,
      );
    }

    return page.copyWith(
      imageData: processedData,
      originalImageData: processedData,
      isProcessed: true,
      editSettings: page.editSettings.copyWith(autoEnhance: autoEnhance),
      corners: detectedCorners != null
          ? ScannedPageCorners(
              topLeft: detectedCorners[0],
              topRight: detectedCorners[1],
              bottomRight: detectedCorners[2],
              bottomLeft: detectedCorners[3],
            )
          : null,
    );
  }

  /// Detect document edges in an image
  Future<List<ui.Offset>?> detectEdges(
    Uint8List imageData,
    int width,
    int height,
  ) async {
    return await _imageProcessingService.detectDocumentEdges(
      imageData,
      width,
      height,
    );
  }

  /// Enhance an image with custom parameters
  Future<Uint8List> enhanceImage(
    Uint8List imageData, {
    double brightness = 0.0,
    double contrast = 1.0,
    double saturation = 1.0,
  }) async {
    return await _imageProcessingService.enhanceImage(
      imageData,
      brightness: brightness,
      contrast: contrast,
      saturation: saturation,
    );
  }

  /// Rotate an image
  Future<Uint8List> rotateImage(Uint8List imageData, double angle) async {
    return await _imageProcessingService.rotateImage(imageData, angle);
  }

  /// Compress an image
  Future<Uint8List> compressImage(
    Uint8List imageData, {
    int quality = 85,
  }) async {
    return await _imageProcessingService.compressImage(
      imageData,
      quality: quality,
    );
  }

  Future<List<ui.Offset>?> _detectDocumentCorners(Uint8List imageData) async {
    try {
      final codec = await ui.instantiateImageCodec(imageData);
      final frame = await codec.getNextFrame();
      return _imageProcessingService.detectDocumentEdges(
        imageData,
        frame.image.width,
        frame.image.height,
      );
    } catch (_) {
      return null;
    }
  }
}
