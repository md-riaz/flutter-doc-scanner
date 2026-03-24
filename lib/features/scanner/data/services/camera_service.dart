import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

/// Service for managing camera operations
class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isStreamingImages => _controller?.value.isStreamingImages ?? false;

  /// Initialize the camera
  Future<void> initialize() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        throw CameraException(
          'camera_permission_denied',
          'Camera permission is required to scan documents',
        );
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw CameraException(
          'no_camera',
          'No camera found on this device',
        );
      }

      // Use the back camera by default
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      // Initialize controller
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  /// Capture an image
  Future<XFile> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw CameraException(
        'camera_not_initialized',
        'Camera is not initialized',
      );
    }

    try {
      final image = await _controller!.takePicture();
      return image;
    } catch (e) {
      throw CameraException(
        'capture_failed',
        'Failed to capture image: ${e.toString()}',
      );
    }
  }

  /// Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller == null) return;
    try {
      await _controller!.setFlashMode(mode);
    } catch (e) {
      // Ignore flash errors on devices that don't support it
    }
  }

  Future<void> startImageStream(
    Future<void> Function(CameraImage image) onFrame,
  ) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw CameraException(
        'camera_not_initialized',
        'Camera is not initialized',
      );
    }

    if (_controller!.value.isStreamingImages) {
      return;
    }

    await _controller!.startImageStream((image) {
      onFrame(image);
    });
  }

  Future<void> stopImageStream() async {
    if (_controller == null || !_controller!.value.isStreamingImages) {
      return;
    }

    try {
      await _controller!.stopImageStream();
    } catch (_) {
      // Ignore stop failures during camera transitions.
    }
  }

  LiveDetectionFrame? buildLiveDetectionFrame(
    CameraImage image, {
    int maxDimension = 720,
  }) {
    try {
      if (image.planes.isEmpty) {
        return null;
      }

      final longestSide =
          image.width > image.height ? image.width : image.height;
      final step = longestSide > maxDimension
          ? (longestSide / maxDimension).ceil()
          : 1;

      final targetWidth = (image.width / step).floor().clamp(1, image.width);
      final targetHeight =
          (image.height / step).floor().clamp(1, image.height);
      final output = img.Image(width: targetWidth, height: targetHeight);

      if (image.format.group == ImageFormatGroup.yuv420) {
        final plane = image.planes.first;
        final bytes = plane.bytes;
        final bytesPerPixel = plane.bytesPerPixel ?? 1;

        for (var y = 0; y < targetHeight; y++) {
          final srcY = y * step;
          final rowOffset = srcY * plane.bytesPerRow;
          for (var x = 0; x < targetWidth; x++) {
            final srcX = x * step;
            final index = rowOffset + (srcX * bytesPerPixel);
            final luma = bytes[index];
            output.setPixelRgba(x, y, luma, luma, luma, 255);
          }
        }
      } else {
        final plane = image.planes.first;
        final bytes = plane.bytes;

        for (var y = 0; y < targetHeight; y++) {
          final srcY = y * step;
          final rowOffset = srcY * plane.bytesPerRow;
          for (var x = 0; x < targetWidth; x++) {
            final srcX = x * step;
            final index = rowOffset + (srcX * 4);
            if (index + 2 >= bytes.length) {
              continue;
            }
            final b = bytes[index];
            final g = bytes[index + 1];
            final r = bytes[index + 2];
            final luma = ((0.299 * r) + (0.587 * g) + (0.114 * b)).round();
            output.setPixelRgba(x, y, luma, luma, luma, 255);
          }
        }
      }

      return LiveDetectionFrame(
        jpegBytes: Uint8List.fromList(img.encodeJpg(output, quality: 72)),
        width: targetWidth,
        height: targetHeight,
      );
    } catch (_) {
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}

class LiveDetectionFrame {
  final Uint8List jpegBytes;
  final int width;
  final int height;

  const LiveDetectionFrame({
    required this.jpegBytes,
    required this.width,
    required this.height,
  });
}
