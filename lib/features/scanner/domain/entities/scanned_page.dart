import 'dart:typed_data';
import 'dart:ui' show Offset;

/// Represents a single scanned page in a document
class ScannedPage {
  final String id;
  final Uint8List imageData;
  final DateTime capturedAt;
  final int pageNumber;
  final bool isProcessed;
  final ScannedPageCorners? corners;

  const ScannedPage({
    required this.id,
    required this.imageData,
    required this.capturedAt,
    required this.pageNumber,
    this.isProcessed = false,
    this.corners,
  });

  ScannedPage copyWith({
    String? id,
    Uint8List? imageData,
    DateTime? capturedAt,
    int? pageNumber,
    bool? isProcessed,
    ScannedPageCorners? corners,
  }) {
    return ScannedPage(
      id: id ?? this.id,
      imageData: imageData ?? this.imageData,
      capturedAt: capturedAt ?? this.capturedAt,
      pageNumber: pageNumber ?? this.pageNumber,
      isProcessed: isProcessed ?? this.isProcessed,
      corners: corners ?? this.corners,
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
