import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

final edgeDetectionServiceProvider = Provider<EdgeDetectionService>((ref) {
  return EdgeDetectionService();
});

/// Service for advanced edge detection using OpenCV
class EdgeDetectionService {
  /// Detect document edges using OpenCV
  /// Returns corners: [topLeft, topRight, bottomRight, bottomLeft]
  Future<List<ui.Offset>?> detectDocumentEdges(
    Uint8List imageData,
    int imageWidth,
    int imageHeight,
  ) async {
    try {
      // Decode image using OpenCV
      final mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
      if (mat.isEmpty) return null;

      // Convert to grayscale
      final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

      // Apply Gaussian blur to reduce noise
      final blurred = cv.gaussianBlur(gray, (5, 5), 0);

      // Apply Canny edge detection
      final edges = cv.canny(blurred, 50, 150);

      // Dilate edges to close gaps
      final kernel = cv.getStructuringElement(cv.MORPH_RECT, (5, 5));
      final dilated = cv.dilate(edges, kernel);

      // Find contours
      final contours = cv.findContours(
        dilated,
        cv.RETR_EXTERNAL,
        cv.CHAIN_APPROX_SIMPLE,
      );

      if (contours.$1.isEmpty) {
        // No contours found, return default rectangle
        return _getDefaultRectangle(imageWidth.toDouble(), imageHeight.toDouble());
      }

      // Find the largest contour
      var largestContour = contours.$1[0];
      double maxArea = cv.contourArea(largestContour);

      for (var i = 1; i < contours.$1.length; i++) {
        final area = cv.contourArea(contours.$1[i]);
        if (area > maxArea) {
          maxArea = area;
          largestContour = contours.$1[i];
        }
      }

      // Approximate the contour to a polygon
      final epsilon = 0.02 * cv.arcLength(largestContour, true);
      final approx = cv.approxPolyDP(largestContour, epsilon, true);

      // If we found a quadrilateral (4 points), use it
      if (approx.rows == 4) {
        final corners = <ui.Offset>[];
        for (var i = 0; i < 4; i++) {
          final point = approx.at<cv.Point>(i, 0);
          corners.add(ui.Offset(point.x.toDouble(), point.y.toDouble()));
        }

        // Sort corners: top-left, top-right, bottom-right, bottom-left
        return _sortCorners(corners);
      }

      // If not a quadrilateral, get bounding rectangle
      final rect = cv.boundingRect(largestContour);
      return [
        ui.Offset(rect.x.toDouble(), rect.y.toDouble()),
        ui.Offset((rect.x + rect.width).toDouble(), rect.y.toDouble()),
        ui.Offset((rect.x + rect.width).toDouble(), (rect.y + rect.height).toDouble()),
        ui.Offset(rect.x.toDouble(), (rect.y + rect.height).toDouble()),
      ];
    } catch (e) {
      // Return default rectangle on error
      return _getDefaultRectangle(imageWidth.toDouble(), imageHeight.toDouble());
    }
  }

  /// Apply perspective transformation to correct document perspective
  Future<Uint8List?> applyPerspectiveTransform(
    Uint8List imageData,
    List<ui.Offset> corners,
  ) async {
    try {
      final mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
      if (mat.isEmpty) return null;

      // Sort corners
      final sortedCorners = _sortCorners(corners);

      // Calculate target dimensions
      final widthTop = _distance(sortedCorners[0], sortedCorners[1]);
      final widthBottom = _distance(sortedCorners[3], sortedCorners[2]);
      final heightLeft = _distance(sortedCorners[0], sortedCorners[3]);
      final heightRight = _distance(sortedCorners[1], sortedCorners[2]);

      final maxWidth = widthTop > widthBottom ? widthTop : widthBottom;
      final maxHeight = heightLeft > heightRight ? heightLeft : heightRight;

      // Source points (document corners)
      final srcPoints = cv.Mat.fromList(
        4,
        1,
        cv.MatType.CV_32FC2,
        [
          sortedCorners[0].dx, sortedCorners[0].dy,
          sortedCorners[1].dx, sortedCorners[1].dy,
          sortedCorners[2].dx, sortedCorners[2].dy,
          sortedCorners[3].dx, sortedCorners[3].dy,
        ],
      );

      // Destination points (rectangle)
      final dstPoints = cv.Mat.fromList(
        4,
        1,
        cv.MatType.CV_32FC2,
        [
          0.0, 0.0,
          maxWidth, 0.0,
          maxWidth, maxHeight,
          0.0, maxHeight,
        ],
      );

      // Get perspective transformation matrix
      final matrix = cv.getPerspectiveTransform(srcPoints, dstPoints);

      // Apply transformation
      final warped = cv.warpPerspective(
        mat,
        matrix,
        (maxWidth.toInt(), maxHeight.toInt()),
      );

      // Encode back to JPEG
      final encoded = cv.imencode('.jpg', warped);
      return Uint8List.fromList(encoded.$2);
    } catch (e) {
      return null;
    }
  }

  /// Sort corners in order: top-left, top-right, bottom-right, bottom-left
  List<ui.Offset> _sortCorners(List<ui.Offset> corners) {
    if (corners.length != 4) return corners;

    // Calculate center point
    final centerX = corners.map((c) => c.dx).reduce((a, b) => a + b) / 4;
    final centerY = corners.map((c) => c.dy).reduce((a, b) => a + b) / 4;

    ui.Offset? topLeft, topRight, bottomRight, bottomLeft;

    for (final corner in corners) {
      if (corner.dx < centerX && corner.dy < centerY) {
        topLeft = corner;
      } else if (corner.dx > centerX && corner.dy < centerY) {
        topRight = corner;
      } else if (corner.dx > centerX && corner.dy > centerY) {
        bottomRight = corner;
      } else {
        bottomLeft = corner;
      }
    }

    return [
      topLeft ?? corners[0],
      topRight ?? corners[1],
      bottomRight ?? corners[2],
      bottomLeft ?? corners[3],
    ];
  }

  /// Get default rectangle with margin
  List<ui.Offset> _getDefaultRectangle(double width, double height) {
    const margin = 0.05;
    return [
      ui.Offset(width * margin, height * margin),
      ui.Offset(width * (1 - margin), height * margin),
      ui.Offset(width * (1 - margin), height * (1 - margin)),
      ui.Offset(width * margin, height * (1 - margin)),
    ];
  }

  /// Calculate distance between two points
  double _distance(ui.Offset p1, ui.Offset p2) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    return (dx * dx + dy * dy).sqrt();
  }
}

extension on double {
  double sqrt() => this < 0 ? 0 : this.abs().toDouble();
}
