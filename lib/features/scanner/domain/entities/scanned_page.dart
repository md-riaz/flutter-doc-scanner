import 'dart:typed_data';
import 'dart:ui' show Offset;

/// Represents a single scanned page in a document
class ScannedPage {
  final String id;
  final Uint8List imageData;
  final Uint8List originalImageData;
  final DateTime capturedAt;
  final int pageNumber;
  final bool isProcessed;
  final ScannedPageCorners? corners;
  final ScannedPageEditSettings editSettings;

  const ScannedPage({
    required this.id,
    required this.imageData,
    Uint8List? originalImageData,
    required this.capturedAt,
    required this.pageNumber,
    this.isProcessed = false,
    this.corners,
    this.editSettings = const ScannedPageEditSettings(),
  }) : originalImageData = originalImageData ?? imageData;

  ScannedPage copyWith({
    String? id,
    Uint8List? imageData,
    Uint8List? originalImageData,
    DateTime? capturedAt,
    int? pageNumber,
    bool? isProcessed,
    ScannedPageCorners? corners,
    ScannedPageEditSettings? editSettings,
  }) {
    return ScannedPage(
      id: id ?? this.id,
      imageData: imageData ?? this.imageData,
      originalImageData: originalImageData ?? this.originalImageData,
      capturedAt: capturedAt ?? this.capturedAt,
      pageNumber: pageNumber ?? this.pageNumber,
      isProcessed: isProcessed ?? this.isProcessed,
      corners: corners ?? this.corners,
      editSettings: editSettings ?? this.editSettings,
    );
  }
}

class ScannedPageEditSettings {
  final double brightness;
  final double contrast;
  final double saturation;
  final double cleanup;
  final double sharpness;
  final bool autoEnhance;
  final int filterIndex;

  const ScannedPageEditSettings({
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.cleanup = 0.0,
    this.sharpness = 0.0,
    this.autoEnhance = true,
    this.filterIndex = 0,
  });

  ScannedPageEditSettings copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? cleanup,
    double? sharpness,
    bool? autoEnhance,
    int? filterIndex,
  }) {
    return ScannedPageEditSettings(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      cleanup: cleanup ?? this.cleanup,
      sharpness: sharpness ?? this.sharpness,
      autoEnhance: autoEnhance ?? this.autoEnhance,
      filterIndex: filterIndex ?? this.filterIndex,
    );
  }
}

/// Represents the four corners of a detected document
class ScannedPageCorners {
  final Offset topLeft;
  final Offset topRight;
  final Offset bottomLeft;
  final Offset bottomRight;

  const ScannedPageCorners({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  List<Offset> toList() {
    return [topLeft, topRight, bottomRight, bottomLeft];
  }
}
