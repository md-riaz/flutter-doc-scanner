import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        imageFormatGroup: ImageFormatGroup.jpeg,
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

  /// Dispose resources
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
