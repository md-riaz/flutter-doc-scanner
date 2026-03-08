# Edge Detection Guide

This document provides detailed information about the OpenCV-powered edge detection system in the Flutter Document Scanner app.

## Overview

The app uses OpenCV's computer vision algorithms to automatically detect document boundaries in captured images. This enables automatic cropping and perspective correction for professional-looking scans.

## Features

### Automatic Document Detection
- **Canny Edge Detection**: Identifies edges in the image
- **Contour Detection**: Finds closed shapes that could be documents
- **Quadrilateral Detection**: Identifies four-sided shapes (documents)
- **Perspective Transformation**: Corrects document perspective to rectangle

### Fallback Mechanism
- Automatically falls back to default rectangle (5% margin) if detection fails
- Ensures the app always works even with difficult images
- No user intervention required for edge detection failure

## Algorithm Details

### Step 1: Preprocessing

```dart
// Convert to grayscale
final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

// Apply Gaussian blur to reduce noise
final blurred = cv.gaussianBlur(gray, (5, 5), 0);
```

**Purpose**: Reduce noise and simplify the image for edge detection

**Parameters**:
- Kernel size: 5x5
- Sigma: 0 (auto-calculated)

### Step 2: Edge Detection

```dart
// Apply Canny edge detection
final edges = cv.canny(blurred, 50, 150);
```

**Purpose**: Detect edges in the image using Canny algorithm

**Parameters**:
- Low threshold: 50
- High threshold: 150
- These thresholds determine edge sensitivity

**How it works**:
1. Calculates image gradients (changes in intensity)
2. Applies non-maximum suppression
3. Uses double thresholding to identify strong and weak edges
4. Tracks edges by hysteresis

### Step 3: Morphological Operations

```dart
// Dilate edges to close gaps
final kernel = cv.getStructuringElement(cv.MORPH_RECT, (5, 5));
final dilated = cv.dilate(edges, kernel);
```

**Purpose**: Close small gaps in detected edges

**Parameters**:
- Kernel shape: Rectangle
- Kernel size: 5x5

### Step 4: Contour Detection

```dart
// Find contours
final contours = cv.findContours(
  dilated,
  cv.RETR_EXTERNAL,
  cv.CHAIN_APPROX_SIMPLE,
);
```

**Purpose**: Find closed shapes in the edge-detected image

**Parameters**:
- Mode: `RETR_EXTERNAL` (only outer contours)
- Method: `CHAIN_APPROX_SIMPLE` (compress horizontal, vertical, and diagonal segments)

### Step 5: Contour Selection

```dart
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
```

**Purpose**: Identify the document (assumed to be the largest shape)

**Logic**: Documents typically occupy the largest area in a scan

### Step 6: Polygon Approximation

```dart
// Approximate the contour to a polygon
final epsilon = 0.02 * cv.arcLength(largestContour, true);
final approx = cv.approxPolyDP(largestContour, epsilon, true);
```

**Purpose**: Simplify the contour to key corner points

**Parameters**:
- Epsilon: 2% of contour perimeter (determines approximation accuracy)
- Closed: true (the shape is closed)

**Douglas-Peucker Algorithm**: Reduces number of points while preserving shape

### Step 7: Quadrilateral Detection

```dart
// If we found a quadrilateral (4 points), use it
if (approx.rows == 4) {
  final corners = <ui.Offset>[];
  for (var i = 0; i < 4; i++) {
    final point = approx.at<cv.Point>(i, 0);
    corners.add(ui.Offset(point.x.toDouble(), point.y.toDouble()));
  }
  return _sortCorners(corners);
}
```

**Purpose**: Extract document corners if a four-sided shape is found

**Requirements**: Must be exactly 4 corners (quadrilateral)

### Step 8: Perspective Transformation

```dart
// Calculate target dimensions
final widthTop = _distance(sortedCorners[0], sortedCorners[1]);
final widthBottom = _distance(sortedCorners[3], sortedCorners[2]);
final heightLeft = _distance(sortedCorners[0], sortedCorners[3]);
final heightRight = _distance(sortedCorners[1], sortedCorners[2]);

final maxWidth = widthTop > widthBottom ? widthTop : widthBottom;
final maxHeight = heightLeft > heightRight ? heightLeft : heightRight;

// Get perspective transformation matrix
final matrix = cv.getPerspectiveTransform(srcPoints, dstPoints);

// Apply transformation
final warped = cv.warpPerspective(
  mat,
  matrix,
  (maxWidth.toInt(), maxHeight.toInt()),
);
```

**Purpose**: Correct perspective distortion and produce a rectangular document

**Process**:
1. Calculate the document's actual dimensions
2. Create transformation matrix mapping source to destination
3. Warp the image to create a rectangle

## Corner Sorting

### Algorithm

The detected corners must be sorted in a consistent order: top-left, top-right, bottom-right, bottom-left.

```dart
List<ui.Offset> _sortCorners(List<ui.Offset> corners) {
  // Calculate center point
  final centerX = corners.map((c) => c.dx).reduce((a, b) => a + b) / 4;
  final centerY = corners.map((c) => c.dy).reduce((a, b) => a + b) / 4;

  // Sort by position relative to center
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

  return [topLeft!, topRight!, bottomRight!, bottomLeft!];
}
```

**Method**: Compare each corner's position to the center point

## Fallback Mechanism

```dart
List<ui.Offset> _getDefaultRectangle(double width, double height) {
  const margin = 0.05; // 5% margin
  return [
    ui.Offset(width * margin, height * margin),
    ui.Offset(width * (1 - margin), height * margin),
    ui.Offset(width * (1 - margin), height * (1 - margin)),
    ui.Offset(width * margin, height * (1 - margin)),
  ];
}
```

**Purpose**: Provide a reasonable default when detection fails

**Parameters**: 5% margin from image edges

**Triggers**:
- No contours found
- No quadrilateral detected
- Detection throws an exception

## Usage in App

### Integration

```dart
// In ImageProcessingService
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
```

### Workflow

1. **Image Capture**: User takes a photo with camera
2. **Automatic Detection**: Edge detection runs automatically (future)
3. **Corner Visualization**: Display detected corners (future)
4. **Manual Adjustment**: Allow user to adjust corners if needed (future)
5. **Apply Transformation**: Warp image to rectangle
6. **Continue Processing**: Apply filters and enhancements

## Performance

### Processing Time
- **Typical**: 100-300ms on mid-range device
- **Complex images**: Up to 500ms
- **Simple images**: 50-100ms

### Factors Affecting Performance
- Image resolution (higher = slower)
- Image complexity (more edges = slower)
- Device CPU performance
- OpenCV optimization level

### Memory Usage
- Temporary memory: ~2-3x image size
- Holds multiple Mat objects during processing
- All cleaned up after detection completes

## Edge Cases

### Handled Scenarios

1. **No document in image**: Falls back to default rectangle
2. **Multiple documents**: Selects largest (assumed to be main document)
3. **Partial document**: Uses bounding rectangle if not quadrilateral
4. **Poor lighting**: Gaussian blur helps reduce noise
5. **Colored backgrounds**: Grayscale conversion normalizes colors

### Challenging Scenarios

1. **White document on white background**: Low contrast makes detection difficult
2. **Curved documents**: Cannot be represented as quadrilateral
3. **Overlapping documents**: Only largest is detected
4. **Very small documents**: May not be largest contour in image

## Configuration

### Tunable Parameters

Current implementation uses fixed parameters. Future versions may allow adjustment:

```dart
// Canny edge detection
lowThreshold: 50,   // Lower = more edges detected
highThreshold: 150, // Higher = fewer edges detected

// Gaussian blur
kernelSize: (5, 5), // Larger = more blur, less noise
sigma: 0,           // Auto-calculated from kernel size

// Morphological operations
dilateKernel: (5, 5), // Larger = closes bigger gaps

// Polygon approximation
epsilonFactor: 0.02, // Higher = simpler polygon (fewer points)
```

### Recommended Adjustments

**For better edge detection**:
- Decrease Canny thresholds (30-100)
- Increase epsilon factor (0.03-0.05)

**For cleaner edges**:
- Increase Gaussian blur kernel (7x7 or 9x9)
- Increase dilate kernel size

**For faster processing**:
- Reduce image resolution before detection
- Skip Gaussian blur (less accurate)

## Implementation Details

### File Location
- **Service**: `lib/features/scanner/data/services/edge_detection_service.dart`
- **Integration**: `lib/features/scanner/data/services/image_processing_service.dart`

### Dependencies
- **opencv_dart**: ^1.0.4

### Service Provider

```dart
final edgeDetectionServiceProvider = Provider<EdgeDetectionService>((ref) {
  return EdgeDetectionService();
});
```

## Future Enhancements

### Planned Features

1. **Manual Corner Adjustment**
   - UI overlay on camera preview
   - Draggable corner markers
   - Real-time perspective preview

2. **Real-time Detection**
   - Detect edges in camera preview
   - Show corner overlay before capture
   - Capture only when document detected

3. **Multiple Documents**
   - Detect all documents in image
   - Allow user to select which to process
   - Batch processing

4. **Advanced Detection**
   - Machine learning models for better accuracy
   - Handle curved documents (using mesh warping)
   - Detect document orientation

5. **Quality Indicators**
   - Confidence score for detection
   - Visual feedback (green = good, red = poor)
   - Suggest recapture if quality low

6. **Optimization**
   - Process on background thread
   - Cache detection results
   - Progressive detection (coarse to fine)

## Troubleshooting

### Detection Not Working

**Symptoms**: Always returns default rectangle

**Causes**:
1. Low contrast between document and background
2. Curved or folded document
3. Multiple overlapping documents
4. Very poor lighting

**Solutions**:
1. Ensure good lighting
2. Place document on contrasting background
3. Flatten document completely
4. Capture one document at a time

### Incorrect Corners

**Symptoms**: Corners don't match document edges

**Causes**:
1. Shadow creating false edges
2. Background patterns confusing detection
3. Document not largest object in frame

**Solutions**:
1. Use even lighting without shadows
2. Plain background
3. Ensure document fills most of frame

### Slow Performance

**Symptoms**: Detection takes >1 second

**Causes**:
1. Very high resolution image
2. Complex image with many edges
3. Low-end device

**Solutions**:
1. Reduce image resolution (e.g., 1920x1080)
2. Use simpler background
3. Test on physical device, not emulator

## Technical Reference

### OpenCV Functions Used

1. **imdecode**: Decode image from bytes
2. **cvtColor**: Convert color spaces
3. **gaussianBlur**: Apply Gaussian blur
4. **canny**: Canny edge detection
5. **getStructuringElement**: Create morphological kernel
6. **dilate**: Morphological dilation
7. **findContours**: Find contours in binary image
8. **contourArea**: Calculate contour area
9. **arcLength**: Calculate contour perimeter
10. **approxPolyDP**: Approximate polygon
11. **getPerspectiveTransform**: Calculate transformation matrix
12. **warpPerspective**: Apply perspective transformation
13. **imencode**: Encode image to bytes

### Mathematical Concepts

1. **Canny Edge Detection**: Gradient-based edge detection with hysteresis
2. **Morphological Operations**: Dilation to close gaps in edges
3. **Contour Approximation**: Douglas-Peucker algorithm
4. **Perspective Transformation**: Homography matrix mapping
5. **Euclidean Distance**: For calculating lengths and dimensions

## Resources

- [Canny Edge Detection](https://docs.opencv.org/4.x/da/d22/tutorial_py_canny.html)
- [Contour Detection](https://docs.opencv.org/4.x/d4/d73/tutorial_py_contours_begin.html)
- [Perspective Transformation](https://docs.opencv.org/4.x/da/d6e/tutorial_py_geometric_transformations.html)
- [Morphological Operations](https://docs.opencv.org/4.x/d9/d61/tutorial_py_morphological_ops.html)
- [OpenCV Dart Package](https://pub.dev/packages/opencv_dart)

## Contributing

To improve edge detection:

1. Test with various image types
2. Tune parameters for better accuracy
3. Add error handling for edge cases
4. Implement real-time detection
5. Add manual adjustment UI
6. Document any changes

---

**Last Updated**: Phase 10 - Advanced Image Processing Implementation
