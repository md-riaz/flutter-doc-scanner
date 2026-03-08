# Manual Corner Adjustment Guide

This document provides detailed information about the manual corner adjustment feature in the Flutter Document Scanner app.

## Overview

The manual corner adjustment UI allows users to fine-tune document boundaries by dragging corner points on the scanned image. This feature ensures perfect document cropping even when automatic edge detection isn't accurate.

## Features

### Auto-Detection
- Automatically detects document corners on screen load using OpenCV
- Uses the same edge detection algorithm as the main scanning workflow
- Fallback to default rectangle (5% margin) if detection fails

### Interactive Corner Points
- **4 draggable corners**: Top-Left (TL), Top-Right (TR), Bottom-Right (BR), Bottom-Left (BL)
- **Visual labels**: Each corner is labeled for easy identification
- **Smooth dragging**: Pan gesture for intuitive corner movement
- **Constrained movement**: Corners stay within image bounds

### Real-time Visual Feedback
- **Quadrilateral overlay**: Lines connecting all 4 corners
- **Semi-transparent mask**: Area outside the document is darkened
- **Highlighted dragging**: Corner becomes brighter when being dragged
- **Corner markers**: 40x40px blue circles with white borders

### User Controls
- **Reset button**: Re-run auto-detection (top-right app bar)
- **Apply button**: Apply perspective transformation
- **Cancel button**: Return without changes
- **Help text**: "Drag the corners to adjust document boundaries"

## User Workflow

### Accessing Corner Adjustment

1. **From Scan Review Screen**:
   - Scan or import documents
   - Navigate to Review screen
   - Tap on any page thumbnail to open preview dialog
   - Tap the "Edit" button
   - Corner adjustment screen opens

### Adjusting Corners

1. **Auto-Detection Phase** (automatic):
   - Screen opens with "Detecting corners..." message
   - OpenCV analyzes the image
   - Corners appear at detected positions
   - If detection fails, default positions are used

2. **Manual Adjustment Phase**:
   - Drag any corner point to desired position
   - Corners are labeled: TL, TR, BR, BL
   - Quadrilateral updates in real-time
   - Area outside document is semi-transparent
   - Reset button available to re-run detection

3. **Apply Transformation**:
   - Tap "Apply" button when satisfied
   - "Applying transformation..." message appears
   - Perspective transformation is applied
   - Page image is updated
   - Returns to Review screen
   - Success message: "Corners applied successfully"

### Navigation Flow

```
ScanReviewScreen
  ↓ Tap page preview
Dialog with page details
  ↓ Tap Edit button
CornerAdjustmentScreen
  ↓ Auto-detect corners (loading)
Corners displayed, ready for adjustment
  ↓ User drags corners (optional)
Real-time quadrilateral updates
  ↓ Tap Apply button
Perspective transformation applied
  ↓ Page updated
Back to ScanReviewScreen
```

## Technical Implementation

### Screen Components

**File**: `lib/features/scanner/presentation/screens/corner_adjustment_screen.dart` (550+ lines)

#### 1. CornerAdjustmentScreen (Main Widget)
- **State**: corners, imageSize, isLoading, isApplying, page
- **Methods**:
  - `_detectCorners()`: Auto-detect using OpenCV
  - `_onCornerDragged()`: Handle corner drag events
  - `_applyTransformation()`: Apply perspective transform
  - `_getDefaultCorners()`: Fallback corner positions

#### 2. _CornerAdjustmentWidget
- **Purpose**: Display image with corner overlay
- **Uses**: LayoutBuilder for responsive sizing
- **Calculates**: Display size maintaining aspect ratio
- **Children**: Image, CustomPaint overlay, draggable corners

#### 3. _DraggableCorner
- **Purpose**: Individual draggable corner marker
- **State**: isDragging
- **Gestures**: onPanStart, onPanUpdate, onPanEnd
- **Display**: 40x40px blue circle with label

#### 4. _CornerOverlayPainter (CustomPainter)
- **Purpose**: Draw quadrilateral and semi-transparent overlay
- **Paints**:
  - Overlay path (everything outside document)
  - Quadrilateral border (blue, 2px)
  - Corner connecting lines (blue, 2px)

### Coordinate Systems

The implementation handles two coordinate systems:

#### Image Coordinates
- **Definition**: Full resolution image dimensions
- **Range**: (0, 0) to (imageWidth, imageHeight)
- **Used for**: Edge detection, transformation

#### Display Coordinates
- **Definition**: Screen-fitted display dimensions
- **Range**: (0, 0) to (displayWidth, displayHeight)
- **Used for**: UI rendering, touch events

#### Conversion
```dart
// Image to Display
displayX = imageX * (displayWidth / imageWidth)
displayY = imageY * (displayHeight / imageHeight)

// Display to Image
imageX = displayX * (imageWidth / displayWidth)
imageY = displayY * (imageHeight / displayHeight)
```

### Integration Points

#### EdgeDetectionService
```dart
// Auto-detect corners
final corners = await edgeService.detectDocumentEdges(
  imageData,
  imageWidth,
  imageHeight,
);

// Apply transformation
final transformed = await edgeService.applyPerspectiveTransform(
  imageData,
  corners,
);
```

#### ScanSessionProvider
```dart
// Update page with transformed image
await ref.read(scanSessionProvider.notifier).updatePageImage(
  pageId,
  transformed,
);
```

#### Router
```dart
// Navigation route
GoRoute(
  path: 'corner-adjustment/:pageId',
  name: 'scanner-corner-adjustment',
  builder: (context, state) {
    final pageId = state.pathParameters['pageId']!;
    return CornerAdjustmentScreen(pageId: pageId);
  },
),
```

## UI Design

### Colors
- **Corner markers**: `Colors.blue.withOpacity(0.6)` (normal)
- **Corner markers (dragging)**: `Colors.blue.withOpacity(0.8)` (highlighted)
- **Border**: `Colors.white` (2px)
- **Quadrilateral lines**: `Colors.blue` (2px)
- **Overlay**: `Colors.black.withOpacity(0.5)`
- **Background**: `Colors.black`
- **Text**: `Colors.white` / `Colors.white70`

### Spacing
- **Corner size**: 40x40px
- **Touch target**: 40x40px (centered on corner point)
- **Help text padding**: 12px all sides
- **Button padding**: 16px all sides
- **Button gap**: 16px between buttons

### Typography
- **App bar title**: Default AppBar text style
- **Help text**: 13px, white70
- **Corner labels**: 11px, bold, white
- **Loading text**: Default, white

### Layout
- **App bar**: Black background, white foreground
- **Help section**: Grey[900] background, top of screen
- **Image area**: Expanded, centered
- **Button area**: Grey[900] background, bottom of screen

## Error Handling

### Detection Errors
- **Symptom**: Auto-detection fails
- **Handling**: Fall back to default corners (5% margin)
- **User feedback**: SnackBar with "Detection failed" message
- **Recovery**: User can still manually adjust or tap Reset

### Page Not Found
- **Symptom**: PageId doesn't exist in session
- **Handling**: Show SnackBar and navigate back
- **User feedback**: "Page not found"

### Transformation Errors
- **Symptom**: Perspective transformation fails
- **Handling**: Stay on screen, show error
- **User feedback**: SnackBar with error message
- **Recovery**: User can try again or cancel

### Invalid Corners
- **Symptom**: Less than 4 corners or null
- **Handling**: Show error, don't apply
- **User feedback**: "Invalid corners"
- **Recovery**: Reset or cancel

## Performance

### Loading Times
- **Auto-detection**: 100-500ms (depends on image complexity)
- **Transformation**: 200-800ms (depends on image size)
- **UI updates**: <16ms (60fps)

### Memory Usage
- **Image decoding**: ~2x image size (temporary)
- **Corner overlay**: Minimal (<1MB)
- **Total overhead**: ~2-3x image size during processing

### Optimization
- Image coordinates stored separately from display
- Only redraw on state change
- Efficient coordinate conversion
- Automatic cleanup after transformation

## Best Practices

### For Users
1. **Start with auto-detection**: Usually accurate
2. **Use Reset button**: If manual adjustment seems off
3. **Adjust all 4 corners**: For best perspective correction
4. **Check preview**: Ensure document fits within bounds
5. **Apply when satisfied**: No need to be pixel-perfect

### For Developers
1. **Test with various image sizes**: Ensure coordinate conversion works
2. **Test edge cases**: Very small/large documents
3. **Verify touch target**: Ensure corners are easy to grab
4. **Check performance**: Monitor transformation time
5. **Handle errors gracefully**: Always provide user feedback

## Troubleshooting

### Corners Not Detecting
**Problem**: Auto-detection always uses default positions

**Causes**:
- Low contrast between document and background
- Curved or folded document
- Very complex background

**Solutions**:
- Manually adjust corners
- Retake photo with better lighting
- Use plain background

### Corners Hard to Drag
**Problem**: Corners don't respond to touch

**Causes**:
- Touch target too small
- Gesture conflict with parent widget

**Solutions**:
- Increase corner marker size (currently 40x40px)
- Adjust gesture detector settings

### Transformation Looks Wrong
**Problem**: Applied transformation doesn't look right

**Causes**:
- Corners in wrong positions
- Invalid corner order
- Coordinate conversion error

**Solutions**:
- Verify corner order (TL, TR, BR, BL)
- Check coordinate conversion math
- Reset and try again

### Slow Performance
**Problem**: Detection or transformation takes too long

**Causes**:
- Very high resolution image
- Complex image processing
- Low-end device

**Solutions**:
- Reduce image resolution before processing
- Test on physical device (not emulator)
- Consider async processing on isolate

## Future Enhancements

### Planned Features
1. **Grid overlay**: Show grid lines for alignment
2. **Snap to edges**: Auto-snap corners to detected edges
3. **Undo/Redo**: History of corner adjustments
4. **Zoom controls**: Zoom in for precise adjustment
5. **Corner validation**: Warn if corners form invalid quadrilateral
6. **Keyboard shortcuts**: Arrow keys for fine adjustment
7. **Multi-touch**: Adjust multiple corners simultaneously
8. **Save presets**: Save common corner configurations

### UI Improvements
1. **Better visual feedback**: Haptic feedback on drag
2. **Corner magnifier**: Magnified view when dragging
3. **Measurement tools**: Show distances and angles
4. **Before/After preview**: Compare original vs adjusted
5. **Crop preview**: Show what final image will look like

### Performance Improvements
1. **Background processing**: Process on isolate
2. **Progressive rendering**: Show low-res preview first
3. **Cached transformations**: Cache intermediate results
4. **GPU acceleration**: Use compute shaders if available

## API Reference

### CornerAdjustmentScreen

```dart
class CornerAdjustmentScreen extends ConsumerStatefulWidget {
  final String pageId;

  const CornerAdjustmentScreen({
    required this.pageId,
  });
}
```

**Parameters**:
- `pageId`: ID of the page to adjust

**Navigation**:
```dart
context.push('/scanner/corner-adjustment/$pageId');
```

### State Methods

```dart
// Auto-detect corners using OpenCV
Future<void> _detectCorners()

// Handle corner drag events
void _onCornerDragged(int index, Offset position, Size displaySize)

// Apply perspective transformation
Future<void> _applyTransformation()

// Get default corners (5% margin)
List<Offset> _getDefaultCorners()
```

## Resources

- [OpenCV Documentation](https://docs.opencv.org/)
- [Perspective Transformation](https://docs.opencv.org/4.x/da/d6e/tutorial_py_geometric_transformations.html)
- [Flutter Custom Paint](https://api.flutter.dev/flutter/widgets/CustomPaint-class.html)
- [Flutter Gestures](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html)
- [Edge Detection Guide](./EDGE_DETECTION.md)

## Contributing

To improve corner adjustment:

1. Test with various document types
2. Gather user feedback on usability
3. Optimize coordinate conversion
4. Add visual enhancements
5. Improve error handling
6. Document any changes

---

**Last Updated**: Phase 11 - Manual Corner Adjustment UI Implementation
