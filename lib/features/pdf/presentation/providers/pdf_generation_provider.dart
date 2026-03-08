import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pdf_document.dart';
import '../../data/repositories/pdf_repository.dart';
import '../../../scanner/domain/entities/scan_session.dart';
import '../../../documents/data/repositories/document_repository.dart';
import '../../../upload_queue/data/repositories/upload_queue_repository.dart';

// State class for PDF generation
class PdfGenerationState {
  final PdfDocument? document;
  final bool isGenerating;
  final String? error;
  final double? progress;

  const PdfGenerationState({
    this.document,
    this.isGenerating = false,
    this.error,
    this.progress,
  });

  PdfGenerationState copyWith({
    PdfDocument? document,
    bool? isGenerating,
    String? error,
    double? progress,
  }) {
    return PdfGenerationState(
      document: document ?? this.document,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
      progress: progress ?? this.progress,
    );
  }
}

// Provider for PDF generation
final pdfGenerationProvider =
    StateNotifierProvider<PdfGenerationNotifier, PdfGenerationState>((ref) {
  final pdfRepository = ref.watch(pdfRepositoryProvider);
  final documentRepository = ref.watch(documentRepositoryProvider);
  final uploadQueueRepository = ref.watch(uploadQueueRepositoryProvider);
  return PdfGenerationNotifier(
    pdfRepository,
    documentRepository,
    uploadQueueRepository,
  );
});

class PdfGenerationNotifier extends StateNotifier<PdfGenerationState> {
  final PdfRepository _pdfRepository;
  final DocumentRepository _documentRepository;
  final UploadQueueRepository _uploadQueueRepository;

  PdfGenerationNotifier(
    this._pdfRepository,
    this._documentRepository,
    this._uploadQueueRepository,
  ) : super(const PdfGenerationState());

  /// Generate a PDF from a scan session
  Future<PdfDocument?> generateFromSession(
    ScanSession session, {
    String? title,
    String? projectId,
    List<String>? tags,
    String? category,
  }) async {
    state = state.copyWith(isGenerating: true, error: null, progress: 0.0);

    try {
      // Simulate progress updates
      state = state.copyWith(progress: 0.3);

      final document = await _pdfRepository.generatePdfFromSession(
        session,
        title: title,
        projectId: projectId,
        tags: tags,
        category: category,
      );

      state = state.copyWith(progress: 0.9);

      // Save to database
      await _documentRepository.saveDocument(document);

      // Add to upload queue
      await _uploadQueueRepository.addToQueue(document.id);

      state = state.copyWith(
        document: document,
        isGenerating: false,
        progress: 1.0,
      );

      return document;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
        progress: 0.0,
      );
      return null;
    }
  }

  /// Delete a PDF document
  Future<void> deletePdf(PdfDocument document) async {
    try {
      await _pdfRepository.deletePdf(document);
      await _documentRepository.deleteDocument(document.id);
      if (state.document?.id == document.id) {
        state = const PdfGenerationState();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Compress a PDF
  Future<void> compressPdf(PdfDocument document) async {
    state = state.copyWith(isGenerating: true, error: null);
    try {
      final compressed = await _pdfRepository.compressPdf(document);
      state = state.copyWith(
        document: compressed,
        isGenerating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
      );
    }
  }

  /// Reset state
  void reset() {
    state = const PdfGenerationState();
  }
}
