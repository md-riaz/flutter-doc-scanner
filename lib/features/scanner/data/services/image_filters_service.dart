import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:image/image.dart' as img;

final imageFiltersServiceProvider = Provider<ImageFiltersService>((ref) {
  return ImageFiltersService();
});

/// Enum for available image filters
enum ImageFilter {
  none,
  blackAndWhite,
  grayscale,
  colorPop,
  magicColor,
  sepia,
  invert,
  sharpen,
  denoise,
  vintage,
  cool,
  warm,
}

/// Service for advanced image filters
class ImageFiltersService {
  /// Apply a filter to an image
  Future<Uint8List> applyFilter(
    Uint8List imageData,
    ImageFilter filter,
  ) async {
    switch (filter) {
      case ImageFilter.none:
        return imageData;
      case ImageFilter.blackAndWhite:
        return _applyBlackAndWhite(imageData);
      case ImageFilter.grayscale:
        return _applyGrayscale(imageData);
      case ImageFilter.colorPop:
        return _applyColorPop(imageData);
      case ImageFilter.magicColor:
        return _applyMagicColor(imageData);
      case ImageFilter.sepia:
        return _applySepia(imageData);
      case ImageFilter.invert:
        return _applyInvert(imageData);
      case ImageFilter.sharpen:
        return _applySharpen(imageData);
      case ImageFilter.denoise:
        return _applyDenoise(imageData);
      case ImageFilter.vintage:
        return _applyVintage(imageData);
      case ImageFilter.cool:
        return _applyCool(imageData);
      case ImageFilter.warm:
        return _applyWarm(imageData);
    }
  }

  /// Black & White - High contrast for documents
  Future<Uint8List> _applyBlackAndWhite(Uint8List imageData) async {
    try {
      final mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
      if (mat.isEmpty) return imageData;

      // Convert to grayscale
      final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

      // Apply adaptive thresholding for better text visibility
      final binary = cv.adaptiveThreshold(
        gray,
        255,
        cv.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv.THRESH_BINARY,
        11,
        2,
      );

      // Encode back to JPEG
      final encoded = cv.imencode('.jpg', binary);
      return Uint8List.fromList(encoded.$2);
    } catch (e) {
      return imageData;
    }
  }

  /// Grayscale - Simple black and white
  Future<Uint8List> _applyGrayscale(Uint8List imageData) async {
    try {
      final mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
      if (mat.isEmpty) return imageData;

      final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
      final encoded = cv.imencode('.jpg', gray);
      return Uint8List.fromList(encoded.$2);
    } catch (e) {
      return imageData;
    }
  }

  /// Color Pop - Enhance saturation
  Future<Uint8List> _applyColorPop(Uint8List imageData) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) return imageData;

      // Increase saturation and contrast
      final enhanced = img.adjustColor(
        image,
        saturation: 1.5,
        contrast: 1.2,
        brightness: 0.05,
      );

      return Uint8List.fromList(img.encodeJpg(enhanced, quality: 90));
    } catch (e) {
      return imageData;
    }
  }

  /// Magic Color - Auto white balance and color correction
  Future<Uint8List> _applyMagicColor(Uint8List imageData) async {
    try {
      final mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
      if (mat.isEmpty) return imageData;

      // Convert to LAB color space
      final lab = cv.cvtColor(mat, cv.COLOR_BGR2LAB);

      // Split channels
      final channels = cv.split(lab);

      // Apply CLAHE (Contrast Limited Adaptive Histogram Equalization) to L channel
      final clahe = cv.CLAHE.create(clipLimit: 2.0, tileGridSize: (8, 8));
      final lChannel = clahe.apply(channels[0]);

      // Merge channels back
      final merged = cv.merge([lChannel, channels[1], channels[2]]);

      // Convert back to BGR
      final result = cv.cvtColor(merged, cv.COLOR_LAB2BGR);

      // Encode back to JPEG
      final encoded = cv.imencode('.jpg', result);
      return Uint8List.fromList(encoded.$2);
    } catch (e) {
      return imageData;
    }
  }

  /// Sepia - Vintage brown tone
  Future<Uint8List> _applySepia(Uint8List imageData) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) return imageData;

      final sepia = img.sepia(image);
      return Uint8List.fromList(img.encodeJpg(sepia, quality: 90));
    } catch (e) {
      return imageData;
    }
  }

  /// Invert - Negative colors
  Future<Uint8List> _applyInvert(Uint8List imageData) async {
    try {
      final mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
      if (mat.isEmpty) return imageData;

      final inverted = cv.bitwise_not(mat);
      final encoded = cv.imencode('.jpg', inverted);
      return Uint8List.fromList(encoded.$2);
    } catch (e) {
      return imageData;
    }
  }

  /// Sharpen - Enhance edges
  Future<Uint8List> _applySharpen(Uint8List imageData) async {
    try {
      final mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
      if (mat.isEmpty) return imageData;

      // Create sharpening kernel
      final kernel = cv.Mat.fromList(
        3,
        3,
        cv.MatType.CV_32F,
        [0, -1, 0, -1, 5, -1, 0, -1, 0],
      );

      // Apply filter
      final sharpened = cv.filter2D(mat, -1, kernel);

      // Encode back to JPEG
      final encoded = cv.imencode('.jpg', sharpened);
      return Uint8List.fromList(encoded.$2);
    } catch (e) {
      return imageData;
    }
  }

  /// Denoise - Reduce noise
  Future<Uint8List> _applyDenoise(Uint8List imageData) async {
    try {
      final mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
      if (mat.isEmpty) return imageData;

      // Apply non-local means denoising
      final denoised = cv.fastNlMeansDenoisingColored(mat, 10, 10, 7, 21);

      // Encode back to JPEG
      final encoded = cv.imencode('.jpg', denoised);
      return Uint8List.fromList(encoded.$2);
    } catch (e) {
      return imageData;
    }
  }

  /// Vintage - Old photo effect
  Future<Uint8List> _applyVintage(Uint8List imageData) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) return imageData;

      // Apply sepia and reduce saturation
      var vintage = img.sepia(image, amount: 0.7);
      vintage = img.adjustColor(vintage, contrast: 0.9, brightness: 0.05);

      return Uint8List.fromList(img.encodeJpg(vintage, quality: 90));
    } catch (e) {
      return imageData;
    }
  }

  /// Cool - Blue tone
  Future<Uint8List> _applyCool(Uint8List imageData) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) return imageData;

      // Adjust RGB channels to add blue tone
      final cool = img.adjustColor(
        image,
        blacks: 0,
        whites: 0,
        reds: 0.95,
        greens: 0.98,
        blues: 1.05,
      );

      return Uint8List.fromList(img.encodeJpg(cool, quality: 90));
    } catch (e) {
      return imageData;
    }
  }

  /// Warm - Orange/red tone
  Future<Uint8List> _applyWarm(Uint8List imageData) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) return imageData;

      // Adjust RGB channels to add warm tone
      final warm = img.adjustColor(
        image,
        blacks: 0,
        whites: 0,
        reds: 1.05,
        greens: 1.02,
        blues: 0.95,
      );

      return Uint8List.fromList(img.encodeJpg(warm, quality: 90));
    } catch (e) {
      return imageData;
    }
  }

  /// Get filter name for display
  String getFilterName(ImageFilter filter) {
    switch (filter) {
      case ImageFilter.none:
        return 'Original';
      case ImageFilter.blackAndWhite:
        return 'B&W Document';
      case ImageFilter.grayscale:
        return 'Grayscale';
      case ImageFilter.colorPop:
        return 'Color Pop';
      case ImageFilter.magicColor:
        return 'Magic Color';
      case ImageFilter.sepia:
        return 'Sepia';
      case ImageFilter.invert:
        return 'Invert';
      case ImageFilter.sharpen:
        return 'Sharpen';
      case ImageFilter.denoise:
        return 'Denoise';
      case ImageFilter.vintage:
        return 'Vintage';
      case ImageFilter.cool:
        return 'Cool';
      case ImageFilter.warm:
        return 'Warm';
    }
  }
}
