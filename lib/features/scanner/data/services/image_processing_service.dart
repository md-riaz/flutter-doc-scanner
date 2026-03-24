import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:doc_scanner/features/scanner/domain/entities/scanned_page.dart';
import 'package:doc_scanner/features/scanner/data/services/edge_detection_service.dart';
import 'package:doc_scanner/features/scanner/data/services/image_filters_service.dart';

final imageProcessingServiceProvider = Provider<ImageProcessingService>((ref) {
  return ImageProcessingService(
    edgeDetectionService: ref.watch(edgeDetectionServiceProvider),
    imageFiltersService: ref.watch(imageFiltersServiceProvider),
  );
});

/// Service for processing scanned images
class ImageProcessingService {
  final EdgeDetectionService edgeDetectionService;
  final ImageFiltersService imageFiltersService;

  ImageProcessingService({
    required this.edgeDetectionService,
    required this.imageFiltersService,
  });
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

  /// Detect document edges (OpenCV-based implementation)
  /// Returns corners: [topLeft, topRight, bottomRight, bottomLeft]
  Future<List<ui.Offset>?> detectDocumentEdges(
    Uint8List imageData,
    int imageWidth,
    int imageHeight,
  ) async {
    return edgeDetectionService.detectDocumentEdges(
      imageData,
      imageWidth,
      imageHeight,
    );
  }

  /// Apply perspective transformation using detected corners
  Future<Uint8List?> applyPerspectiveTransform(
    Uint8List imageData,
    List<ui.Offset> corners,
  ) async {
    return edgeDetectionService.applyPerspectiveTransform(imageData, corners);
  }

  /// Apply an image filter
  Future<Uint8List> applyFilter(
    Uint8List imageData,
    ImageFilter filter,
  ) async {
    return imageFiltersService.applyFilter(imageData, filter);
  }

  /// Get filter name for display
  String getFilterName(ImageFilter filter) {
    return imageFiltersService.getFilterName(filter);
  }

  Future<Uint8List> applyDocumentEdits(
    Uint8List imageData, {
    required ScannedPageEditSettings settings,
    int? maxDimension,
  }) async {
    var edited = await compute(
      _applyDocumentEditsInBackground,
      <String, dynamic>{
        'imageData': imageData,
        'brightness': settings.brightness,
        'contrast': settings.contrast,
        'saturation': settings.saturation,
        'cleanup': settings.cleanup,
        'sharpness': settings.sharpness,
        'autoEnhance': settings.autoEnhance,
        'maxDimension': maxDimension,
      },
    );

    final filter = ImageFilter.values[settings.filterIndex];
    if (filter != ImageFilter.none) {
      edited = await imageFiltersService.applyFilter(
        edited,
        filter,
        maxDimension: maxDimension,
      );
    }

    return edited;
  }

  Future<Uint8List> applyPreviewDocumentEdits(
    Uint8List imageData, {
    required ScannedPageEditSettings settings,
  }) {
    return applyDocumentEdits(
      imageData,
      settings: settings,
      maxDimension: 1400,
    );
  }

  Future<ScanQualityAssessment> analyzeDocumentQuality(
    Uint8List imageData,
  ) {
    return compute(_analyzeDocumentQualityInBackground, imageData);
  }
}

Uint8List _applyDocumentEditsInBackground(Map<String, dynamic> payload) {
  final imageData = payload['imageData'] as Uint8List;
  final brightness = payload['brightness'] as double;
  final contrast = payload['contrast'] as double;
  final saturation = payload['saturation'] as double;
  final cleanup = payload['cleanup'] as double;
  final sharpness = payload['sharpness'] as double;
  final autoEnhance = payload['autoEnhance'] as bool;
  final maxDimension = payload['maxDimension'] as int?;

  try {
    var image = img.decodeImage(imageData);
    if (image == null) {
      return imageData;
    }

    if (maxDimension != null) {
      final longestSide =
          image.width > image.height ? image.width : image.height;
      if (longestSide > maxDimension) {
        image = image.width >= image.height
            ? img.copyResize(image, width: maxDimension)
            : img.copyResize(image, height: maxDimension);
      }
    }

    if (autoEnhance) {
      image = img.adjustColor(
        image,
        brightness: 0.04,
        contrast: 1.12,
        saturation: 1.02,
      );
      image = img.convolution(
        image,
        filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
      );
    }

    image = img.adjustColor(
      image,
      brightness: brightness,
      contrast: contrast,
      saturation: saturation,
    );

    if (cleanup > 0) {
      image = _applyDocumentCleanup(image, cleanup);
    }

    if (sharpness > 0) {
      image = _applySharpness(image, sharpness);
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  } catch (_) {
    return imageData;
  }
}

img.Image _applyDocumentCleanup(img.Image image, double cleanup) {
  final cleanupRatio = cleanup.clamp(0.0, 1.0);
  final whiteLift = 18 + (cleanupRatio * 44);
  final shadowLift = cleanupRatio * 22;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r.toDouble();
      final g = pixel.g.toDouble();
      final b = pixel.b.toDouble();
      final luminance = (0.299 * r) + (0.587 * g) + (0.114 * b);

      var nextR = r;
      var nextG = g;
      var nextB = b;

      if (luminance > 150) {
        final whitenFactor = ((luminance - 150) / 105.0) * cleanupRatio;
        nextR = r + ((255 - r) * whitenFactor) + whiteLift * 0.15;
        nextG = g + ((255 - g) * whitenFactor) + whiteLift * 0.15;
        nextB = b + ((255 - b) * whitenFactor) + whiteLift * 0.15;
      } else {
        nextR = r + shadowLift;
        nextG = g + shadowLift;
        nextB = b + shadowLift;
      }

      image.setPixelRgba(
        x,
        y,
        nextR.clamp(0, 255).round(),
        nextG.clamp(0, 255).round(),
        nextB.clamp(0, 255).round(),
        pixel.a.toInt(),
      );
    }
  }

  return image;
}

img.Image _applySharpness(img.Image image, double sharpness) {
  final sharpened = img.convolution(
    image,
    filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
  );
  final amount = sharpness.clamp(0.0, 1.0);
  return img.adjustColor(
    sharpened,
    contrast: 1.0 + (amount * 0.08),
  );
}

ScanQualityAssessment _analyzeDocumentQualityInBackground(Uint8List imageData) {
  try {
    var image = img.decodeImage(imageData);
    if (image == null) {
      return const ScanQualityAssessment(warnings: ['Unreadable']);
    }

    final longestSide = image.width > image.height ? image.width : image.height;
    if (longestSide > 900) {
      image = image.width >= image.height
          ? img.copyResize(image, width: 900)
          : img.copyResize(image, height: 900);
    }

    var brightnessSum = 0.0;
    var brightnessSquaredSum = 0.0;
    var edgeEnergy = 0.0;
    var hotspotPixels = 0;
    var samples = 0;
    var topForegroundX = 0.0;
    var topForegroundCount = 0;
    var bottomForegroundX = 0.0;
    var bottomForegroundCount = 0;

    for (var y = 0; y < image.height - 1; y++) {
      for (var x = 0; x < image.width - 1; x++) {
        final pixel = image.getPixel(x, y);
        final right = image.getPixel(x + 1, y);
        final below = image.getPixel(x, y + 1);

        final luma = _pixelLuma(pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble());
        final lumaRight = _pixelLuma(
          right.r.toDouble(),
          right.g.toDouble(),
          right.b.toDouble(),
        );
        final lumaBelow = _pixelLuma(
          below.r.toDouble(),
          below.g.toDouble(),
          below.b.toDouble(),
        );

        brightnessSum += luma;
        brightnessSquaredSum += luma * luma;
        edgeEnergy += (luma - lumaRight).abs() + (luma - lumaBelow).abs();
        if (luma > 245) {
          hotspotPixels++;
        }
        if (luma < 140) {
          if (y < image.height * 0.25) {
            topForegroundX += x;
            topForegroundCount++;
          } else if (y > image.height * 0.75) {
            bottomForegroundX += x;
            bottomForegroundCount++;
          }
        }
        samples++;
      }
    }

    if (samples == 0) {
      return const ScanQualityAssessment(warnings: ['Unreadable']);
    }

    final avgBrightness = brightnessSum / samples;
    final variance = (brightnessSquaredSum / samples) - (avgBrightness * avgBrightness);
    final contrastSpread = variance <= 0 ? 0.0 : variance.sqrtSafe();
    final sharpness = edgeEnergy / (samples * 2);
    final glareRatio = hotspotPixels / samples;
    final topCenter = topForegroundCount == 0
        ? image.width / 2
        : topForegroundX / topForegroundCount;
    final bottomCenter = bottomForegroundCount == 0
        ? image.width / 2
        : bottomForegroundX / bottomForegroundCount;
    final skewOffsetRatio = ((topCenter - bottomCenter).abs() / image.width);

    final warnings = <String>[];
    if (avgBrightness < 80) {
      warnings.add('Too dark');
    } else if (avgBrightness > 220) {
      warnings.add('Overexposed');
    }
    if (contrastSpread < 28) {
      warnings.add('Low contrast');
    }
    if (sharpness < 12) {
      warnings.add('Blurry');
    }
    if (glareRatio > 0.08) {
      warnings.add('Glare');
    }
    if (skewOffsetRatio > 0.08) {
      warnings.add('Skewed');
    }

    final score = (100 -
            (avgBrightness < 80 ? 20 : 0) -
            (avgBrightness > 220 ? 18 : 0) -
            (contrastSpread < 28 ? 18 : 0) -
            (sharpness < 12 ? 24 : 0) -
            (glareRatio > 0.08 ? 14 : 0) -
            (skewOffsetRatio > 0.08 ? 12 : 0))
        .clamp(20, 100)
        .toInt();

    return ScanQualityAssessment(
      score: score,
      averageBrightness: avgBrightness,
      contrastSpread: contrastSpread,
      sharpness: sharpness,
      glareRatio: glareRatio,
      skewOffsetRatio: skewOffsetRatio,
      warnings: warnings,
    );
  } catch (_) {
    return const ScanQualityAssessment(warnings: ['Unreadable']);
  }
}

double _pixelLuma(double r, double g, double b) {
  return (0.299 * r) + (0.587 * g) + (0.114 * b);
}

class ScanQualityAssessment {
  final int score;
  final double averageBrightness;
  final double contrastSpread;
  final double sharpness;
  final double glareRatio;
  final double skewOffsetRatio;
  final List<String> warnings;

  const ScanQualityAssessment({
    this.score = 100,
    this.averageBrightness = 0,
    this.contrastSpread = 0,
    this.sharpness = 0,
    this.glareRatio = 0,
    this.skewOffsetRatio = 0,
    this.warnings = const [],
  });

  bool get hasWarnings => warnings.isNotEmpty;
}

extension on double {
  double sqrtSafe() {
    if (this <= 0) {
      return 0;
    }
    return switch (this) {
      final value when value <= 1 => value,
      _ => _sqrtNewton(this),
    };
  }
}

double _sqrtNewton(double value) {
  var estimate = value / 2;
  for (var i = 0; i < 8; i++) {
    estimate = (estimate + (value / estimate)) / 2;
  }
  return estimate;
}
