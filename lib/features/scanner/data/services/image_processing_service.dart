import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

final imageProcessingServiceProvider = Provider<ImageProcessingService>((ref) {
  return ImageProcessingService();
});

/// Service for processing scanned images
class ImageProcessingService {
  /// Enhance image (brightness, contrast, sharpness)
  Future<Uint8List> enhanceImage(
    Uint8List imageData, {
    double brightness = 0.0,
    double contrast = 1.0,
    double saturation = 1.0,
  }) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Apply brightness
      var enhanced = img.adjustColor(
        image,
        brightness: brightness,
        contrast: contrast,
        saturation: saturation,
      );

      // Sharpen the image
      enhanced = img.convolution(
        enhanced,
        filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
      );

      return Uint8List.fromList(img.encodeJpg(enhanced, quality: 90));
    } catch (e) {
      throw Exception('Failed to enhance image: ${e.toString()}');
    }
  }

  /// Crop image to specified corners
  Future<Uint8List> cropImage(
    Uint8List imageData,
    List<ui.Offset> corners,
  ) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Find bounding box
      final minX = corners.map((c) => c.dx).reduce((a, b) => a < b ? a : b);
      final maxX = corners.map((c) => c.dx).reduce((a, b) => a > b ? a : b);
      final minY = corners.map((c) => c.dy).reduce((a, b) => a < b ? a : b);
      final maxY = corners.map((c) => c.dy).reduce((a, b) => a > b ? a : b);

      final width = (maxX - minX).toInt();
      final height = (maxY - minY).toInt();

      // Crop image
      final cropped = img.copyCrop(
        image,
        x: minX.toInt(),
        y: minY.toInt(),
        width: width,
        height: height,
      );

      return Uint8List.fromList(img.encodeJpg(cropped, quality: 90));
    } catch (e) {
      throw Exception('Failed to crop image: ${e.toString()}');
    }
  }

  /// Auto-enhance scanned document
  Future<Uint8List> autoEnhanceDocument(Uint8List imageData) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Convert to grayscale
      var enhanced = img.grayscale(image);

      // Increase contrast
      enhanced = img.contrast(enhanced, contrast: 120);

      // Apply adaptive threshold for better text visibility
      enhanced = img.adjustColor(enhanced, brightness: 0.1, contrast: 1.2);

      // Sharpen
      enhanced = img.convolution(
        enhanced,
        filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
      );

      return Uint8List.fromList(img.encodeJpg(enhanced, quality: 90));
    } catch (e) {
      throw Exception('Failed to auto-enhance: ${e.toString()}');
    }
  }

  /// Rotate image by specified angle
  Future<Uint8List> rotateImage(
    Uint8List imageData,
    double angle,
  ) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final rotated = img.copyRotate(image, angle: angle);
      return Uint8List.fromList(img.encodeJpg(rotated, quality: 90));
    } catch (e) {
      throw Exception('Failed to rotate image: ${e.toString()}');
    }
  }

  /// Compress image to target size
  Future<Uint8List> compressImage(
    Uint8List imageData, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      var image = img.decodeImage(imageData);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if dimensions are specified
      if (maxWidth != null || maxHeight != null) {
        image = img.copyResize(
          image,
          width: maxWidth,
          height: maxHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    } catch (e) {
      throw Exception('Failed to compress image: ${e.toString()}');
    }
  }

  /// Detect document edges (simple implementation)
  /// Returns corners: [topLeft, topRight, bottomRight, bottomLeft]
  Future<List<ui.Offset>?> detectDocumentEdges(
    Uint8List imageData,
    int imageWidth,
    int imageHeight,
  ) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) return null;

      // For now, return a rectangle with 5% margin
      // In production, use OpenCV or similar for real edge detection
      final margin = 0.05;
      final w = imageWidth.toDouble();
      final h = imageHeight.toDouble();

      return [
        ui.Offset(w * margin, h * margin), // top left
        ui.Offset(w * (1 - margin), h * margin), // top right
        ui.Offset(w * (1 - margin), h * (1 - margin)), // bottom right
        ui.Offset(w * margin, h * (1 - margin)), // bottom left
      ];
    } catch (e) {
      return null;
    }
  }
}
