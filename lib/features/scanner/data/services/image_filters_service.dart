import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:opencv_dart/opencv_dart.dart' as cv;

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

/// Service for advanced image filters.
/// Heavy work runs off the UI isolate to keep preview interactions responsive.
class ImageFiltersService {
  Future<Uint8List> applyFilter(
    Uint8List imageData,
    ImageFilter filter, {
    int? maxDimension,
  }) async {
    try {
      return await compute(
        _applyFilterInBackground,
        <String, dynamic>{
          'imageData': imageData,
          'filterIndex': filter.index,
          'maxDimension': maxDimension,
        },
      );
    } catch (_) {
      return imageData;
    }
  }

  Future<Uint8List> applyPreviewFilter(
    Uint8List imageData,
    ImageFilter filter,
  ) {
    return applyFilter(
      imageData,
      filter,
      maxDimension: 1400,
    );
  }

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

Future<Uint8List> _applyFilterInBackground(Map<String, dynamic> payload) async {
  final imageData = payload['imageData'] as Uint8List;
  final filterIndex = payload['filterIndex'] as int;
  final maxDimension = payload['maxDimension'] as int?;
  final filter = ImageFilter.values[filterIndex];

  final sourceData = maxDimension == null
      ? imageData
      : _resizeForPreview(imageData, maxDimension);

  switch (filter) {
    case ImageFilter.none:
      return sourceData;
    case ImageFilter.blackAndWhite:
      return _applyBlackAndWhite(sourceData);
    case ImageFilter.grayscale:
      return _applyGrayscale(sourceData);
    case ImageFilter.colorPop:
      return _applyColorPop(sourceData);
    case ImageFilter.magicColor:
      return _applyMagicColor(sourceData);
    case ImageFilter.sepia:
      return _applySepia(sourceData);
    case ImageFilter.invert:
      return _applyInvert(sourceData);
    case ImageFilter.sharpen:
      return _applySharpen(sourceData);
    case ImageFilter.denoise:
      return _applyDenoise(sourceData);
    case ImageFilter.vintage:
      return _applyVintage(sourceData);
    case ImageFilter.cool:
      return _applyCool(sourceData);
    case ImageFilter.warm:
      return _applyWarm(sourceData);
  }
}

Uint8List _resizeForPreview(Uint8List imageData, int maxDimension) {
  try {
    final image = img.decodeImage(imageData);
    if (image == null) return imageData;

    final longestSide =
        image.width > image.height ? image.width : image.height;
    if (longestSide <= maxDimension) {
      return imageData;
    }

    final resized = image.width >= image.height
        ? img.copyResize(image, width: maxDimension)
        : img.copyResize(image, height: maxDimension);

    return Uint8List.fromList(img.encodeJpg(resized, quality: 88));
  } catch (_) {
    return imageData;
  }
}

Uint8List _applyBlackAndWhite(Uint8List imageData) {
  try {
    final mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
    if (mat.isEmpty) return imageData;

    final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
    final binary = cv.adaptiveThreshold(
      gray,
      255,
      cv.ADAPTIVE_THRESH_GAUSSIAN_C,
      cv.THRESH_BINARY,
      11,
      2,
    );

    final encoded = cv.imencode('.jpg', binary);
    return Uint8List.fromList(encoded.$2);
  } catch (_) {
    return imageData;
  }
}

Uint8List _applyGrayscale(Uint8List imageData) {
  try {
    final mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
    if (mat.isEmpty) return imageData;

    final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
    final encoded = cv.imencode('.jpg', gray);
    return Uint8List.fromList(encoded.$2);
  } catch (_) {
    return imageData;
  }
}

Uint8List _applyColorPop(Uint8List imageData) {
  try {
    final image = img.decodeImage(imageData);
    if (image == null) return imageData;

    final enhanced = img.adjustColor(
      image,
      saturation: 1.5,
      contrast: 1.2,
      brightness: 0.05,
    );

    return Uint8List.fromList(img.encodeJpg(enhanced, quality: 90));
  } catch (_) {
    return imageData;
  }
}

Uint8List _applyMagicColor(Uint8List imageData) {
  try {
    final image = img.decodeImage(imageData);
    if (image == null) return imageData;

    final enhanced = img.adjustColor(
      image,
      contrast: 1.3,
      brightness: 0.05,
    );

    return Uint8List.fromList(img.encodeJpg(enhanced, quality: 90));
  } catch (_) {
    return imageData;
  }
}

Uint8List _applySepia(Uint8List imageData) {
  try {
    final image = img.decodeImage(imageData);
    if (image == null) return imageData;

    final sepia = img.sepia(image);
    return Uint8List.fromList(img.encodeJpg(sepia, quality: 90));
  } catch (_) {
    return imageData;
  }
}

Uint8List _applyInvert(Uint8List imageData) {
  try {
    final mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
    if (mat.isEmpty) return imageData;

    final inverted = cv.bitwiseNOT(mat);
    final encoded = cv.imencode('.jpg', inverted);
    return Uint8List.fromList(encoded.$2);
  } catch (_) {
    return imageData;
  }
}

Uint8List _applySharpen(Uint8List imageData) {
  try {
    final mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
    if (mat.isEmpty) return imageData;

    final kernel = cv.Mat.fromList(
      3,
      3,
      cv.MatType.CV_32FC1,
      [0.0, -1.0, 0.0, -1.0, 5.0, -1.0, 0.0, -1.0, 0.0],
    );

    final sharpened = cv.filter2D(mat, -1, kernel);
    final encoded = cv.imencode('.jpg', sharpened);
    return Uint8List.fromList(encoded.$2);
  } catch (_) {
    return imageData;
  }
}

Uint8List _applyDenoise(Uint8List imageData) {
  try {
    final mat = cv.imdecode(imageData, cv.IMREAD_COLOR);
    if (mat.isEmpty) return imageData;

    final denoised = cv.fastNlMeansDenoisingColored(
      mat,
      h: 10.0,
      hColor: 10.0,
      templateWindowSize: 7,
      searchWindowSize: 21,
    );

    final encoded = cv.imencode('.jpg', denoised);
    return Uint8List.fromList(encoded.$2);
  } catch (_) {
    return imageData;
  }
}

Uint8List _applyVintage(Uint8List imageData) {
  try {
    final image = img.decodeImage(imageData);
    if (image == null) return imageData;

    var vintage = img.sepia(image, amount: 0.7);
    vintage = img.adjustColor(vintage, contrast: 0.9, brightness: 0.05);

    return Uint8List.fromList(img.encodeJpg(vintage, quality: 90));
  } catch (_) {
    return imageData;
  }
}

Uint8List _applyCool(Uint8List imageData) {
  try {
    final image = img.decodeImage(imageData);
    if (image == null) return imageData;

    final cool = img.adjustColor(
      image,
      saturation: 1.1,
      brightness: 0.02,
    );

    return Uint8List.fromList(img.encodeJpg(cool, quality: 90));
  } catch (_) {
    return imageData;
  }
}

Uint8List _applyWarm(Uint8List imageData) {
  try {
    final image = img.decodeImage(imageData);
    if (image == null) return imageData;

    final warm = img.adjustColor(
      image,
      saturation: 1.15,
      brightness: 0.03,
    );

    return Uint8List.fromList(img.encodeJpg(warm, quality: 90));
  } catch (_) {
    return imageData;
  }
}
