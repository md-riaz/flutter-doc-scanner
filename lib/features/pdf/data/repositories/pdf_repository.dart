import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/pdf_document.dart';
import '../services/pdf_service.dart';
import '../../../scanner/domain/entities/scan_session.dart';

final pdfRepositoryProvider = Provider<PdfRepository>((ref) {
  final pdfService = ref.watch(pdfServiceProvider);
  return PdfRepository(pdfService);
});

/// Repository for managing PDF documents
class PdfRepository {
  final PdfService _pdfService;
  final _uuid = const Uuid();

  PdfRepository(this._pdfService);

  /// Generate a PDF from a scan session
  Future<PdfDocument> generatePdfFromSession(
    ScanSession session, {
    String? title,
    String? projectId,
    List<String>? tags,
    String? category,
  }) async {
    try {
      // Extract image data from pages
      final images = session.pages.map((page) => page.imageData).toList();

      // Generate filename
      final fileName = _pdfService.generateFileName(
        baseName: title ?? session.title ?? 'scan',
      );

      // Generate PDF
      final filePath = await _pdfService.generatePdf(
        images: images,
        fileName: fileName,
      );

      // Get file size
      final fileSize = await _pdfService.getPdfSize(filePath);

      // Create PDF document entity
      final pdfDocument = PdfDocument(
        id: _uuid.v4(),
        title: title ?? session.title ?? 'Untitled Document',
        filePath: filePath,
        pageCount: session.pages.length,
        fileSizeBytes: fileSize,
        createdAt: DateTime.now(),
        projectId: projectId ?? session.projectId,
        tags: tags ?? [],
        category: category,
      );

      return pdfDocument;
    } catch (e) {
      throw Exception('Failed to generate PDF: ${e.toString()}');
    }
  }

  /// Generate a PDF from image data
  Future<PdfDocument> generatePdfFromImages(
    List<Uint8List> images, {
    required String title,
    String? projectId,
    List<String>? tags,
    String? category,
  }) async {
    try {
      // Generate filename
      final fileName = _pdfService.generateFileName(baseName: title);

      // Generate PDF
      final filePath = await _pdfService.generatePdf(
        images: images,
        fileName: fileName,
      );

      // Get file size
      final fileSize = await _pdfService.getPdfSize(filePath);

      // Validate file size
      if (!_pdfService.isFileSizeValid(fileSize)) {
        await _pdfService.deletePdf(filePath);
        throw Exception('PDF file size exceeds maximum allowed size');
      }

      // Create PDF document entity
      final pdfDocument = PdfDocument(
        id: _uuid.v4(),
        title: title,
        filePath: filePath,
        pageCount: images.length,
        fileSizeBytes: fileSize,
        createdAt: DateTime.now(),
        projectId: projectId,
        tags: tags ?? [],
        category: category,
      );

      return pdfDocument;
    } catch (e) {
      throw Exception('Failed to generate PDF: ${e.toString()}');
    }
  }

  /// Delete a PDF document
  Future<void> deletePdf(PdfDocument document) async {
    await _pdfService.deletePdf(document.filePath);
  }

  /// Check if a PDF exists
  Future<bool> pdfExists(PdfDocument document) async {
    return await _pdfService.pdfExists(document.filePath);
  }

  /// Compress a PDF
  Future<PdfDocument> compressPdf(
    PdfDocument document, {
    int quality = 70,
  }) async {
    try {
      final compressedPath = await _pdfService.compressPdf(
        document.filePath,
        quality: quality,
      );

      final fileSize = await _pdfService.getPdfSize(compressedPath);

      return document.copyWith(
        filePath: compressedPath,
        fileSizeBytes: fileSize,
      );
    } catch (e) {
      throw Exception('Failed to compress PDF: ${e.toString()}');
    }
  }

  /// Get all PDFs
  Future<List<String>> getAllPdfPaths() async {
    final files = await _pdfService.getAllPdfs();
    return files.map((file) => file.path).toList();
  }
}
