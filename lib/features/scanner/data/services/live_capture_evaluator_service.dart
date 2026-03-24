import 'dart:ui';

import 'package:doc_scanner/core/constants/app_constants.dart';
import 'package:doc_scanner/features/scanner/data/services/image_processing_service.dart';

enum ScanCaptureMode {
  manual,
  auto,
}

enum AutoCaptureState {
  idle,
  searching,
  locking,
  ready,
  capturing,
  cooldown,
}

class LiveCaptureAssessment {
  final List<Offset>? corners;
  final ScanQualityAssessment quality;
  final bool hasDocument;
  final bool isFallbackRectangle;
  final bool passesFraming;
  final bool passesQuality;
  final bool isStable;
  final bool nearEdge;
  final double aspectRatio;
  final double areaRatio;
  final double movement;
  final List<String> blockingWarnings;
  final String guidanceMessage;

  const LiveCaptureAssessment({
    required this.corners,
    required this.quality,
    required this.hasDocument,
    required this.isFallbackRectangle,
    required this.passesFraming,
    required this.passesQuality,
    required this.isStable,
    required this.nearEdge,
    required this.aspectRatio,
    required this.areaRatio,
    required this.movement,
    required this.blockingWarnings,
    required this.guidanceMessage,
  });

  bool get hasUsableDocument => hasDocument && !isFallbackRectangle;
  bool get isGoodFrame => hasUsableDocument && passesFraming && passesQuality;
  bool get isReady => isGoodFrame && isStable;
}

class LiveCaptureEvaluatorService {
  const LiveCaptureEvaluatorService();

  LiveCaptureAssessment evaluate({
    required List<Offset>? corners,
    required ScanQualityAssessment quality,
    required bool isFallbackRectangle,
    List<Offset>? previousCorners,
  }) {
    final hasDocument = corners != null && corners.length == 4;
    if (!hasDocument || isFallbackRectangle) {
      return LiveCaptureAssessment(
        corners: corners,
        quality: quality,
        hasDocument: hasDocument,
        isFallbackRectangle: isFallbackRectangle,
        passesFraming: false,
        passesQuality: false,
        isStable: false,
        nearEdge: false,
        aspectRatio: 0,
        areaRatio: 0,
        movement: 1,
        blockingWarnings: const [],
        guidanceMessage: 'Find a document in the frame',
      );
    }

    final normalizedCorners = corners;
    final areaRatio = _polygonArea(normalizedCorners).abs();
    final nearEdge = normalizedCorners.any(
      (corner) =>
          corner.dx < AppConstants.autoCaptureEdgeMarginRatio ||
          corner.dx > 1 - AppConstants.autoCaptureEdgeMarginRatio ||
          corner.dy < AppConstants.autoCaptureEdgeMarginRatio ||
          corner.dy > 1 - AppConstants.autoCaptureEdgeMarginRatio,
    );
    final aspectRatio = _aspectRatio(normalizedCorners);
    final passesArea = areaRatio >= AppConstants.autoCaptureMinAreaRatio;
    final passesAspect = aspectRatio >= AppConstants.autoCaptureMinAspectRatio &&
        aspectRatio <= AppConstants.autoCaptureMaxAspectRatio;
    final passesFraming = passesArea && passesAspect && !nearEdge;

    final blockingWarnings = quality.warnings
        .where(
          (warning) => warning == 'Too dark' ||
              warning == 'Blurry' ||
              warning == 'Glare' ||
              warning == 'Skewed',
        )
        .toList();
    final passesQuality = blockingWarnings.isEmpty;

    final movement = previousCorners == null || previousCorners.length != 4
        ? 1
        : _averageMovement(normalizedCorners, previousCorners);
    final isStable =
        movement <= AppConstants.autoCaptureMaxMovementThreshold;

    final guidanceMessage = _guidanceMessage(
      blockingWarnings: blockingWarnings,
      passesArea: passesArea,
      nearEdge: nearEdge,
      passesAspect: passesAspect,
      isStable: isStable,
    );

    return LiveCaptureAssessment(
      corners: normalizedCorners,
      quality: quality,
      hasDocument: true,
      isFallbackRectangle: false,
      passesFraming: passesFraming,
      passesQuality: passesQuality,
      isStable: isStable,
      nearEdge: nearEdge,
      aspectRatio: aspectRatio,
      areaRatio: areaRatio,
      movement: movement,
      blockingWarnings: blockingWarnings,
      guidanceMessage: guidanceMessage,
    );
  }

  String _guidanceMessage({
    required List<String> blockingWarnings,
    required bool passesArea,
    required bool nearEdge,
    required bool passesAspect,
    required bool isStable,
  }) {
    if (blockingWarnings.isNotEmpty) {
      return blockingWarnings.take(2).join(' | ');
    }
    if (!passesArea) {
      return 'Move closer';
    }
    if (nearEdge || !passesAspect) {
      return 'Fit the page inside the frame';
    }
    if (!isStable) {
      return 'Hold steady';
    }
    return 'Locked. Capturing soon.';
  }

  double _averageMovement(List<Offset> current, List<Offset> previous) {
    var total = 0.0;
    for (var i = 0; i < current.length; i++) {
      total += (current[i] - previous[i]).distance;
    }
    return total / current.length.toDouble();
  }

  double _aspectRatio(List<Offset> corners) {
    final topWidth = (corners[1] - corners[0]).distance;
    final bottomWidth = (corners[2] - corners[3]).distance;
    final leftHeight = (corners[3] - corners[0]).distance;
    final rightHeight = (corners[2] - corners[1]).distance;
    final width = (topWidth + bottomWidth) / 2;
    final height = (leftHeight + rightHeight) / 2;
    if (height == 0) {
      return 0;
    }
    return width / height;
  }

  double _polygonArea(List<Offset> corners) {
    var area = 0.0;
    for (var i = 0; i < corners.length; i++) {
      final next = corners[(i + 1) % corners.length];
      area += (corners[i].dx * next.dy) - (next.dx * corners[i].dy);
    }
    return area.abs() / 2;
  }
}
