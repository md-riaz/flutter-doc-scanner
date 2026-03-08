# Image Filters Guide

This document provides detailed information about the advanced image filters available in the Flutter Document Scanner app.

## Overview

The app includes 12 professional image filters powered by OpenCV and the `image` package, optimized for document scanning and photo enhancement.

## Available Filters

### 1. Original (None)
- **Use Case**: No modifications, original image
- **Technical Details**: Returns the image as captured
- **Best For**: When you want the unmodified scan

### 2. Black & White (B&W Document)
- **Use Case**: High contrast documents, text recognition
- **Technical Details**:
  - Converts to grayscale
  - Applies adaptive threshold with Gaussian method
  - Block size: 11, constant: 2
  - Optimized for text visibility
- **Best For**: Text documents, receipts, contracts, forms
- **Algorithm**: OpenCV adaptive thresholding

### 3. Grayscale
- **Use Case**: Simple black and white conversion
- **Technical Details**: Standard RGB to grayscale conversion
- **Best For**: General purpose black and white images
- **Algorithm**: OpenCV color space conversion (BGR2GRAY)

### 4. Color Pop
- **Use Case**: Enhance color vibrancy
- **Technical Details**:
  - Saturation boost: 1.5x
  - Contrast increase: 1.2x
  - Brightness adjustment: +0.05
- **Best For**: Photos, colorful documents, presentations
- **Algorithm**: Color adjustment via image package

### 5. Magic Color
- **Use Case**: Auto color correction and white balance
- **Technical Details**:
  - Converts to LAB color space
  - Applies CLAHE (Contrast Limited Adaptive Histogram Equalization)
  - Clip limit: 2.0
  - Tile grid size: 8x8
  - Processes only luminance channel
- **Best For**: Poorly lit images, mixed lighting conditions
- **Algorithm**: OpenCV CLAHE in LAB color space

### 6. Sepia
- **Use Case**: Vintage/artistic effect
- **Technical Details**: Standard sepia tone transformation
- **Best For**: Artistic documents, creative projects
- **Algorithm**: Sepia color matrix transformation

### 7. Invert
- **Use Case**: Negative colors, dark mode viewing
- **Technical Details**: Bitwise NOT operation on all pixels
- **Best For**: Viewing white documents on dark screens, special effects
- **Algorithm**: OpenCV bitwise_not

### 8. Sharpen
- **Use Case**: Enhance edges and details
- **Technical Details**:
  - Applies sharpening kernel
  - Matrix: [0, -1, 0, -1, 5, -1, 0, -1, 0]
  - Emphasizes edges and fine details
- **Best For**: Blurry images, enhancing text clarity
- **Algorithm**: OpenCV filter2D with sharpening kernel

### 9. Denoise
- **Use Case**: Remove noise from image
- **Technical Details**:
  - Non-local means denoising algorithm
  - Filter strength: 10
  - Template window size: 7
  - Search window size: 21
- **Best For**: Noisy images, low-light photos, grainy scans
- **Algorithm**: OpenCV fastNlMeansDenoisingColored

### 10. Vintage
- **Use Case**: Old photo aesthetic
- **Technical Details**:
  - Sepia tone at 70% strength
  - Reduced contrast: 0.9x
  - Slight brightness increase: +0.05
- **Best For**: Artistic projects, nostalgic effect
- **Algorithm**: Combined sepia and color adjustment

### 11. Cool
- **Use Case**: Blue-tinted modern look
- **Technical Details**:
  - Red channel: 0.95x
  - Green channel: 0.98x
  - Blue channel: 1.05x
- **Best For**: Modern documents, cool aesthetic
- **Algorithm**: RGB channel adjustment

### 12. Warm
- **Use Case**: Orange/red-tinted cozy look
- **Technical Details**:
  - Red channel: 1.05x
  - Green channel: 1.02x
  - Blue channel: 0.95x
- **Best For**: Warm aesthetic, vintage look
- **Algorithm**: RGB channel adjustment

## Filter Implementation

### Architecture

```
ImageFiltersService
├── applyFilter(imageData, filter) - Main entry point
├── _applyBlackAndWhite() - OpenCV adaptive threshold
├── _applyGrayscale() - OpenCV grayscale conversion
├── _applyColorPop() - Image package color adjustment
├── _applyMagicColor() - OpenCV CLAHE in LAB space
├── _applySepia() - Image package sepia
├── _applyInvert() - OpenCV bitwise NOT
├── _applySharpen() - OpenCV filter2D
├── _applyDenoise() - OpenCV non-local means
├── _applyVintage() - Combined effects
├── _applyCool() - RGB adjustment
└── _applyWarm() - RGB adjustment
```

### File Locations

- **Service**: `lib/features/scanner/data/services/image_filters_service.dart`
- **Integration**: `lib/features/scanner/data/services/image_processing_service.dart`
- **UI**: `lib/features/scanner/presentation/screens/page_preview_screen.dart`

## Usage in App

### User Workflow

1. **Capture or Import**: Take a photo or import from gallery
2. **Preview Screen**: View the captured image
3. **Filter Selector**: Scroll through 12 filter options (horizontal scrollable)
4. **Apply Filter**: Tap on any filter to preview in real-time
5. **Loading State**: See loading indicator while filter applies
6. **Continue or Finish**: Add more pages or finish with selected filter

### Technical Flow

```dart
// Apply filter
final filterService = ref.read(imageFiltersServiceProvider);
final filtered = await filterService.applyFilter(
  imageData,
  ImageFilter.blackAndWhite,
);

// Update page with filtered image
await ref.read(scanSessionProvider.notifier).updatePageImage(
  pageId,
  filtered,
);
```

## Performance Considerations

### Processing Time (Approximate)

- **Fast** (<100ms): Original, Grayscale, Invert
- **Medium** (100-300ms): Sepia, Cool, Warm, Vintage, Color Pop
- **Slower** (300-500ms): Black & White, Sharpen
- **Slowest** (500ms-1s): Magic Color, Denoise

*Times vary based on device performance and image resolution*

### Memory Usage

- All filters operate on a copy of the image
- Original image is preserved
- Encoded as JPEG with 90% quality after processing
- Typical memory overhead: 2-3x original image size during processing

## Best Practices

### For Documents

1. **Text Documents**: Use Black & White for best OCR results
2. **Color Documents**: Use Magic Color for auto correction
3. **Receipts**: Use Black & White or Sharpen
4. **Photographs**: Use Color Pop or original

### For Photos

1. **Portraits**: Use Color Pop or Warm
2. **Landscapes**: Use Cool or Color Pop
3. **Low Light**: Use Magic Color or Denoise
4. **Artistic**: Use Vintage or Sepia

## Troubleshooting

### Filter Not Applying
- Check image format is supported (JPEG, PNG)
- Ensure sufficient memory available
- Verify opencv_dart package is properly installed

### Slow Performance
- Consider reducing image resolution before filtering
- Use faster filters (Grayscale, Invert) for quick previews
- Test on physical device rather than emulator

### Unexpected Results
- Magic Color may produce unexpected results on already-corrected images
- Denoise can blur sharp images - use only for noisy images
- Black & White adaptive threshold works best with good lighting

## Technical Dependencies

- **opencv_dart**: ^1.0.4 - Core OpenCV functionality
- **image**: ^4.1.3 - Image manipulation library
- **flutter_riverpod**: State management for filter preview

## Future Enhancements

Planned improvements:

1. **Manual Adjustment**: Sliders for fine-tuning filter parameters
2. **Custom Filters**: Save and reuse custom filter settings
3. **Batch Processing**: Apply filters to multiple pages at once
4. **Filter Presets**: Quick access to frequently used filters
5. **Before/After View**: Side-by-side comparison
6. **Filter Strength**: Adjustable intensity for each filter
7. **AI Enhancement**: ML-based auto enhancement

## API Reference

### ImageFilter Enum

```dart
enum ImageFilter {
  none,           // Original
  blackAndWhite,  // Adaptive threshold
  grayscale,      // Simple B&W
  colorPop,       // Enhanced saturation
  magicColor,     // Auto white balance
  sepia,          // Brown tone
  invert,         // Negative
  sharpen,        // Edge enhancement
  denoise,        // Noise reduction
  vintage,        // Old photo
  cool,           // Blue tint
  warm,           // Orange/red tint
}
```

### Service Methods

```dart
class ImageFiltersService {
  // Apply a filter to an image
  Future<Uint8List> applyFilter(Uint8List imageData, ImageFilter filter);

  // Get human-readable filter name
  String getFilterName(ImageFilter filter);
}
```

## Examples

### Applying a Filter

```dart
final service = ImageFiltersService();
final filteredImage = await service.applyFilter(
  originalImageBytes,
  ImageFilter.blackAndWhite,
);
```

### Getting Filter Name

```dart
final service = ImageFiltersService();
final name = service.getFilterName(ImageFilter.magicColor); // "Magic Color"
```

## Resources

- [OpenCV Documentation](https://docs.opencv.org/)
- [CLAHE Algorithm](https://docs.opencv.org/4.x/d5/daf/tutorial_py_histogram_equalization.html)
- [Non-Local Means Denoising](https://docs.opencv.org/4.x/d5/d69/tutorial_py_non_local_means.html)
- [Image Package](https://pub.dev/packages/image)

## Contributing

To add a new filter:

1. Add enum value to `ImageFilter` in `image_filters_service.dart`
2. Implement the filter method (e.g., `_applyMyFilter()`)
3. Add case to `applyFilter()` switch statement
4. Add name to `getFilterName()` switch statement
5. Update this documentation
6. Test with various image types

---

**Last Updated**: Phase 10 - Advanced Image Processing Implementation
