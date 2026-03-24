import 'package:doc_scanner/features/scanner/data/services/image_processing_service.dart';
import 'package:doc_scanner/features/scanner/data/services/live_capture_evaluator_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const evaluator = LiveCaptureEvaluatorService();
  const stableDocument = [
    Offset(0.2, 0.15),
    Offset(0.8, 0.15),
    Offset(0.82, 0.88),
    Offset(0.18, 0.88),
  ];

  group('LiveCaptureEvaluatorService', () {
    test('valid polygon with good quality and stability is ready', () {
      const quality = ScanQualityAssessment(
        score: 92,
        warnings: [],
      );

      final assessment = evaluator.evaluate(
        corners: stableDocument,
        quality: quality,
        isFallbackRectangle: false,
        previousCorners: const [
          Offset(0.201, 0.151),
          Offset(0.799, 0.151),
          Offset(0.821, 0.879),
          Offset(0.181, 0.879),
        ],
      );

      expect(assessment.isGoodFrame, isTrue);
      expect(assessment.isReady, isTrue);
      expect(assessment.guidanceMessage, 'Locked. Capturing soon.');
    });

    test('fallback rectangle is never ready', () {
      const quality = ScanQualityAssessment(score: 90, warnings: []);
      final assessment = evaluator.evaluate(
        corners: const [
          Offset(0.05, 0.05),
          Offset(0.95, 0.05),
          Offset(0.95, 0.95),
          Offset(0.05, 0.95),
        ],
        quality: quality,
        isFallbackRectangle: true,
      );

      expect(assessment.hasUsableDocument, isFalse);
      expect(assessment.isReady, isFalse);
    });

    test('blocking quality warnings prevent auto capture', () {
      const quality = ScanQualityAssessment(
        score: 40,
        warnings: ['Too dark', 'Blurry'],
      );

      final assessment = evaluator.evaluate(
        corners: stableDocument,
        quality: quality,
        isFallbackRectangle: false,
        previousCorners: stableDocument,
      );

      expect(assessment.passesQuality, isFalse);
      expect(assessment.isReady, isFalse);
      expect(assessment.guidanceMessage, 'Too dark | Blurry');
    });

    test('page near edge stays out of ready state', () {
      const quality = ScanQualityAssessment(score: 88, warnings: []);
      final assessment = evaluator.evaluate(
        corners: const [
          Offset(0.03, 0.12),
          Offset(0.88, 0.12),
          Offset(0.89, 0.9),
          Offset(0.02, 0.9),
        ],
        quality: quality,
        isFallbackRectangle: false,
        previousCorners: const [
          Offset(0.031, 0.12),
          Offset(0.881, 0.12),
          Offset(0.891, 0.899),
          Offset(0.021, 0.899),
        ],
      );

      expect(assessment.nearEdge, isTrue);
      expect(assessment.passesFraming, isFalse);
      expect(assessment.isReady, isFalse);
    });

    test('unstable corners remain in locking/searching conditions', () {
      const quality = ScanQualityAssessment(score: 89, warnings: []);
      final assessment = evaluator.evaluate(
        corners: stableDocument,
        quality: quality,
        isFallbackRectangle: false,
        previousCorners: const [
          Offset(0.27, 0.19),
          Offset(0.87, 0.19),
          Offset(0.89, 0.94),
          Offset(0.25, 0.94),
        ],
      );

      expect(assessment.isGoodFrame, isTrue);
      expect(assessment.isStable, isFalse);
      expect(assessment.isReady, isFalse);
      expect(assessment.guidanceMessage, 'Hold steady');
    });
  });
}
