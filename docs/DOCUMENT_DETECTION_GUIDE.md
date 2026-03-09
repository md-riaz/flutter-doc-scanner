# Document Detection Implementation Guide

This guide explains how the document detection features work in the Flutter Document Scanner application, matching the CamScanner-like functionality described in the requirements.

---

## Overview: Three Core Layers

The application is built around three main layers:

1. **Camera + Document Detection** (OpenCV-powered)
2. **Image Enhancement (Scan Look)** (12 professional filters)
3. **Document Management + Export** (Multi-page PDFs)

---

## Layer 1: Camera Capture + Document Detection

### Architecture

```
CameraScreen (Flutter UI)
   ↓
CameraService (camera package)
   ↓
EdgeDetectionService (OpenCV)
   ↓
Detected corners [topLeft, topRight, bottomRight, bottomLeft]
   ↓
CornerAdjustmentScreen (CustomPainter overlay)
```

### Edge Detection Algorithm

**File:** `lib/features/scanner/data/services/edge_detection_service.dart`

The `detectDocumentEdges()` method implements a complete document detection pipeline:

#### Step 1: Preprocessing
```dart
// Convert to grayscale
final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

// Apply Gaussian blur to reduce noise
final blurred = cv.gaussianBlur(gray, (5, 5), 0);
```

#### Step 2: Edge Detection
```dart
// Apply Canny edge detection
final edges = cv.canny(blurred, 50, 150);

// Dilate edges to close gaps
final kernel = cv.getStructuringElement(cv.MORPH_RECT, (5, 5));
final dilated = cv.dilate(edges, kernel);
```

#### Step 3: Contour Detection
```dart
// Find contours
final contours = cv.findContours(
  dilated,
  cv.RETR_EXTERNAL,
  cv.CHAIN_APPROX_SIMPLE,
);

// Find the largest contour (assumed to be the document)
var largestContour = contours.$1[0];
double maxArea = cv.contourArea(largestContour);
```

#### Step 4: Rectangle Detection
```dart
// Approximate the contour to a polygon
final epsilon = 0.02 * cv.arcLength(largestContour, true);
final approx = cv.approxPolyDP(largestContour, epsilon, true);

// Check if it's a quadrilateral (4 points)
if (approx.length == 4) {
  // Use detected corners
}
```

#### Step 5: Corner Sorting
```dart
// Sort corners: top-left, top-right, bottom-right, bottom-left
return _sortCorners(corners);
```

### Fallback Mechanism

If detection fails or no contours are found:
```dart
// Return default rectangle with 5% margin
return _getDefaultRectangle(imageWidth, imageHeight);
```

### Usage Example

```dart
// Get edge detection service
final edgeDetectionService = ref.read(edgeDetectionServiceProvider);

// Detect document edges
final corners = await edgeDetectionService.detectDocumentEdges(
  imageData,    // Uint8List of image bytes
  imageWidth,   // Image width in pixels
  imageHeight,  // Image height in pixels
);

if (corners != null) {
  // corners = [topLeft, topRight, bottomRight, bottomLeft]
  // Each corner is a ui.Offset(x, y)
}
```

---

## Layer 2: Perspective Correction

### The Scan Effect

Transforms a skewed document photo into a flat, rectangular scan:

```
Before:                After:
 /--------/            +--------+
|        |             |        |
|       /              |        |
/------/               +--------+
```

### Implementation

**File:** `lib/features/scanner/data/services/edge_detection_service.dart`

The `applyPerspectiveTransform()` method:

#### Step 1: Calculate Target Dimensions
```dart
// Measure width from top and bottom edges
final widthTop = _distance(corners[0], corners[1]);
final widthBottom = _distance(corners[3], corners[2]);

// Measure height from left and right edges
final heightLeft = _distance(corners[0], corners[3]);
final heightRight = _distance(corners[1], corners[2]);

// Use maximum dimensions to avoid cropping
final maxWidth = widthTop > widthBottom ? widthTop : widthBottom;
final maxHeight = heightLeft > heightRight ? heightLeft : heightRight;
```

#### Step 2: Define Source and Destination Points
```dart
// Source points (actual document corners in image)
final srcPoints = cv.VecPoint2f.fromList([
  cv.Point2f(corners[0].dx, corners[0].dy),  // top-left
  cv.Point2f(corners[1].dx, corners[1].dy),  // top-right
  cv.Point2f(corners[2].dx, corners[2].dy),  // bottom-right
  cv.Point2f(corners[3].dx, corners[3].dy),  // bottom-left
]);

// Destination points (perfect rectangle)
final dstPoints = cv.VecPoint2f.fromList([
  cv.Point2f(0.0, 0.0),                      // top-left
  cv.Point2f(maxWidth, 0.0),                 // top-right
  cv.Point2f(maxWidth, maxHeight),           // bottom-right
  cv.Point2f(0.0, maxHeight),                // bottom-left
]);
```

#### Step 3: Apply Perspective Transform
```dart
// Get transformation matrix
final matrix = cv.getPerspectiveTransform2f(srcPoints, dstPoints);

// Warp the image
final warped = cv.warpPerspective(
  mat,
  matrix,
  (maxWidth.toInt(), maxHeight.toInt()),
);
```

#### Step 4: Encode Result
```dart
// Encode to JPEG for efficient storage
final encoded = cv.imencode('.jpg', warped);
return Uint8List.fromList(encoded.$2);
```

### Usage Example

```dart
// Apply perspective correction
final correctedImage = await edgeDetectionService.applyPerspectiveTransform(
  imageData,  // Original image bytes
  corners,    // 4 corners from detection
);

// correctedImage is now a flat, rectangular scan
```

---

## Layer 3: Image Enhancement Filters

### Filter Pipeline

**File:** `lib/features/scanner/data/services/image_filters_service.dart`

The application provides 12 professional filters:

### Document Filters

#### 1. Black & White Document (Recommended for text)
```dart
// Grayscale conversion
final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

// Adaptive thresholding for clear text
final binary = cv.adaptiveThreshold(
  gray,
  255,
  cv.ADAPTIVE_THRESH_GAUSSIAN_C,
  cv.THRESH_BINARY,
  11,  // Block size
  2,   // Constant subtracted from mean
);
```

**Best for:** Documents with text, receipts, contracts, printed materials

#### 2. Grayscale
```dart
final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
```

**Best for:** Simple black and white conversion

#### 3. Sharpen (Enhance edges)
```dart
// Sharpening kernel
final kernel = cv.Mat.fromList(
  3, 3, cv.MatType.CV_32FC1,
  [0.0, -1.0, 0.0, -1.0, 5.0, -1.0, 0.0, -1.0, 0.0],
);

// Apply filter
final sharpened = cv.filter2D(mat, -1, kernel);
```

**Best for:** Blurry documents, improving text clarity

#### 4. Denoise (Remove noise)
```dart
// Non-local means denoising
final denoised = cv.fastNlMeansDenoisingColored(
  mat,
  h: 10.0,
  hColor: 10.0,
  templateWindowSize: 7,
  searchWindowSize: 21
);
```

**Best for:** Photos taken in low light, noisy images

### Color Enhancement Filters

#### 5. Color Pop
```dart
final enhanced = img.adjustColor(
  image,
  saturation: 1.5,   // Boost colors
  contrast: 1.2,     // Increase contrast
  brightness: 0.05,  // Slight brightness
);
```

**Best for:** Color documents, product photos, presentations

#### 6. Magic Color (Auto enhancement)
```dart
final enhanced = img.adjustColor(
  image,
  contrast: 1.3,     // Auto contrast
  brightness: 0.05,  // Auto brightness
);
```

**Best for:** General purpose auto-enhancement

### Artistic Filters

#### 7. Sepia (Vintage brown)
```dart
final sepia = img.sepia(image);
```

#### 8. Vintage (Old photo)
```dart
var vintage = img.sepia(image, amount: 0.7);
vintage = img.adjustColor(vintage, contrast: 0.9);
```

#### 9. Cool (Blue tone)
```dart
final cool = img.adjustColor(image, saturation: 1.1);
```

#### 10. Warm (Orange/red tone)
```dart
final warm = img.adjustColor(image, saturation: 1.15);
```

#### 11. Invert (Negative)
```dart
final inverted = cv.bitwiseNOT(mat);
```

#### 12. Original (No filter)
Returns the original image unchanged.

### Filter Selection Guide

| Document Type | Recommended Filter | Alternative |
|---------------|-------------------|-------------|
| Text documents | B&W Document | Grayscale |
| Receipts | B&W Document | Sharpen |
| Forms | B&W Document | Grayscale |
| Color brochures | Color Pop | Magic Color |
| Photos | Magic Color | Color Pop |
| Presentations | Color Pop | Sharpen |
| Old documents | Denoise → B&W | Sharpen |
| ID cards | Sharpen | Magic Color |

### Usage Example

```dart
// Get filter service
final filterService = ref.read(imageFiltersServiceProvider);

// Apply filter
final filteredImage = await filterService.applyFilter(
  imageData,                    // Original image bytes
  ImageFilter.blackAndWhite,    // Selected filter
);

// Use filtered image
```

---

## Manual Corner Adjustment

### Interactive UI

**File:** `lib/features/scanner/presentation/screens/corner_adjustment_screen.dart`

The corner adjustment screen provides a professional interface for manual correction:

### Features

1. **Automatic Detection on Load**
   ```dart
   await _detectCorners();  // Runs OpenCV detection automatically
   ```

2. **4 Draggable Corners**
   - Top-Left (TL)
   - Top-Right (TR)
   - Bottom-Right (BR)
   - Bottom-Left (BL)

3. **Visual Feedback**
   - Blue circular corner markers (40x40px)
   - Corner labels for easy identification
   - Highlighted corners when dragging
   - Semi-transparent mask outside document

4. **Real-time Preview**
   - Quadrilateral overlay updates as corners move
   - Blue border showing document boundaries

5. **User Controls**
   - **Reset button**: Re-run automatic detection
   - **Apply button**: Apply perspective transformation
   - **Cancel button**: Return without changes

### Coordinate System

The implementation handles two coordinate systems:

```dart
// Display coordinates (screen pixels)
final displayOffset = Offset(x, y);

// Image coordinates (actual image pixels)
final imageOffset = Offset(
  displayOffset.dx * (imageWidth / displayWidth),
  displayOffset.dy * (imageHeight / displayHeight),
);
```

### Usage Flow

1. User opens corner adjustment screen
2. System runs automatic detection
3. User sees detected corners as draggable points
4. User drags corners to adjust if needed
5. User clicks "Apply"
6. System applies perspective transformation
7. Updated image is saved to the page

### Navigation

```dart
// Navigate to corner adjustment
context.push('/scanner/corner-adjustment/$pageId');
```

---

## Complete Workflow

### End-to-End Scanning Process

```
1. CameraScreen
   ↓ User captures photo

2. PagePreviewScreen
   ↓ Select filter (12 options)
   ↓ Auto-enhance if desired

3. ScanReviewScreen
   ↓ View all pages
   ↓ Edit corners if needed
   ↓ Reorder pages
   ↓ Add more pages

4. CornerAdjustmentScreen (if Edit clicked)
   ↓ Adjust corners manually
   ↓ Apply perspective transform

5. ScanReviewScreen
   ↓ Click "Generate PDF"

6. PdfGenerationScreen
   ↓ Enter title, category, tags, project
   ↓ Generate PDF

7. DocumentsScreen
   ↓ View, open, share, or upload
```

---

## Performance Considerations

### Edge Detection Performance

- **Simple images**: 50-100ms
- **Typical images**: 100-300ms
- **Complex images**: 300-500ms

### Filter Application Performance

- **Fast filters** (Grayscale, Invert): 50-100ms
- **Medium filters** (B&W, Sharpen, Color Pop): 100-200ms
- **Slow filters** (Denoise): 300-500ms

### Optimization Tips

1. **Run detection on background thread** (already implemented via async/await)
2. **Cache filter thumbnails** for preview selector
3. **Compress images** before storage
4. **Use lower resolution** for preview
5. **Apply filters progressively** for interactive use

---

## Testing the Features

### Manual Testing Checklist

- [ ] Capture photo of document with camera
- [ ] Verify automatic edge detection highlights document
- [ ] Adjust corners manually if needed
- [ ] Apply B&W Document filter to text document
- [ ] Apply Color Pop filter to color document
- [ ] Test all 12 filters
- [ ] Capture multiple pages (2-5 pages)
- [ ] Reorder pages with drag and drop
- [ ] Generate multi-page PDF
- [ ] Open PDF in viewer
- [ ] Share PDF via system dialog
- [ ] Import image from gallery
- [ ] Verify edge detection on gallery import
- [ ] Test with various document types (receipts, forms, books, etc.)

### Test Document Types

1. **Text Documents**
   - Receipts (small text, low contrast)
   - Contracts (black text on white)
   - Books (printed pages)
   - Forms (boxes and text)

2. **Color Documents**
   - Brochures (colorful graphics)
   - Presentations (slides)
   - Photos (color images)
   - ID cards (text + photo)

3. **Challenging Cases**
   - Low contrast documents
   - Curved or wrinkled pages
   - Shadowed documents
   - Multiple objects in frame
   - Non-white backgrounds

---

## API Reference

### EdgeDetectionService

```dart
/// Detect document edges using OpenCV
Future<List<ui.Offset>?> detectDocumentEdges(
  Uint8List imageData,  // Image bytes (JPEG or PNG)
  int imageWidth,       // Image width in pixels
  int imageHeight,      // Image height in pixels
)

/// Apply perspective transformation
Future<Uint8List?> applyPerspectiveTransform(
  Uint8List imageData,      // Original image bytes
  List<ui.Offset> corners,  // 4 corners: [TL, TR, BR, BL]
)
```

### ImageFiltersService

```dart
/// Apply a filter to an image
Future<Uint8List> applyFilter(
  Uint8List imageData,  // Image bytes
  ImageFilter filter,   // Selected filter
)

/// Get filter display name
String getFilterName(ImageFilter filter)
```

### Available Filters

```dart
enum ImageFilter {
  none,           // Original (no filter)
  blackAndWhite,  // High contrast for text
  grayscale,      // Simple B&W
  colorPop,       // Enhanced colors
  magicColor,     // Auto enhancement
  sepia,          // Brown vintage
  invert,         // Negative colors
  sharpen,        // Edge enhancement
  denoise,        // Noise reduction
  vintage,        // Old photo effect
  cool,           // Blue tone
  warm,           // Orange/red tone
}
```

---

## Troubleshooting

### Edge Detection Issues

**Problem:** Detection fails or finds wrong rectangle

**Solutions:**
1. Ensure document has clear edges
2. Use good lighting (avoid shadows)
3. Place document on contrasting background
4. Use manual corner adjustment
5. Try different angles

**Problem:** Performance is slow

**Solutions:**
1. Reduce image resolution before detection
2. Run on background isolate
3. Cache detection results
4. Skip detection for gallery imports if corners are known

### Filter Issues

**Problem:** Filters produce unexpected results

**Solutions:**
1. Try different filters for different document types
2. Use B&W Document for text-heavy documents
3. Use Color Pop for color documents
4. Apply sharpen filter for blurry images
5. Use denoise for noisy/grainy images

**Problem:** Filter application is slow

**Solutions:**
1. Use faster filters when possible
2. Show loading indicator during processing
3. Apply filters progressively
4. Cache filtered results

---

## Best Practices

### For Developers

1. **Always handle edge detection failures** with fallback rectangle
2. **Sort corners correctly** before perspective transform
3. **Validate image dimensions** before processing
4. **Cache detection results** to avoid re-processing
5. **Show loading indicators** for long operations
6. **Use appropriate filters** for document types
7. **Compress images** after processing to save storage
8. **Test on various devices** for performance

### For Users

1. **Use good lighting** when capturing documents
2. **Place documents flat** on contrasting surface
3. **Fill the frame** with the document
4. **Hold camera parallel** to document surface
5. **Adjust corners manually** for curved pages
6. **Choose appropriate filter** for document type
7. **Use B&W Document filter** for text-heavy documents
8. **Capture multiple times** if result is not satisfactory

---

## Future Enhancements

### Possible Improvements

1. **Real-time Edge Detection**
   - Live overlay during camera preview
   - Automatic capture when document detected
   - Visual feedback for document alignment

2. **Advanced Shadow Removal**
   - Dedicated shadow detection algorithm
   - Illumination correction
   - Adaptive local enhancement

3. **Enhanced CLAHE Implementation**
   - Full CLAHE for Magic Color filter
   - LAB color space conversion
   - Better auto color correction

4. **Batch Processing**
   - Process multiple documents at once
   - Apply same filter to all pages
   - Bulk corner adjustment

5. **Document Templates**
   - Predefined corner positions for common formats
   - A4, Letter, Business Card, etc.
   - Quick capture for repeated use

6. **Machine Learning Enhancement**
   - ML-based document detection
   - Text recognition for OCR
   - Smart cropping suggestions

---

## References

### OpenCV Documentation

- [Canny Edge Detection](https://docs.opencv.org/4.x/da/d22/tutorial_py_canny.html)
- [Contour Detection](https://docs.opencv.org/4.x/d4/d73/tutorial_py_contours_begin.html)
- [Perspective Transformation](https://docs.opencv.org/4.x/da/d6e/tutorial_py_geometric_transformations.html)

### Flutter Packages

- [opencv_dart](https://pub.dev/packages/opencv_dart) - OpenCV bindings for Dart
- [image](https://pub.dev/packages/image) - Image processing in Dart
- [camera](https://pub.dev/packages/camera) - Camera access
- [pdf](https://pub.dev/packages/pdf) - PDF generation

### Related Documentation

- [IMPLEMENTATION_STATUS.md](./IMPLEMENTATION_STATUS.md) - Overall project status
- [EDGE_DETECTION.md](./EDGE_DETECTION.md) - Edge detection details
- [FILTERS.md](./FILTERS.md) - Filter implementations
- [CORNER_ADJUSTMENT.md](./CORNER_ADJUSTMENT.md) - Corner adjustment UI

---

**Last Updated:** March 9, 2026
**Version:** 1.0
**Author:** Flutter Document Scanner Team
