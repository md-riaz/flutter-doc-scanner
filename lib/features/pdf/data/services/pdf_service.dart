import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../../core/constants/app_constants.dart';

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

/// Service for generating PDF documents from scanned images
class PdfService {
  /// Generate a PDF from a list of image bytes
  Future<String> generatePdf({
    required List<Uint8List> images,
    required String fileName,
    PdfPageFormat? pageFormat,
    int quality = 85,
  }) async {
    try {
      // Create PDF document
      final pdf = pw.Document();

      // Add each image as a page
      for (int i = 0; i < images.length; i++) {
        final image = images[i];

        // Decode image to get dimensions
        final pdfImage = pw.MemoryImage(image);

        // Add page with image
        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat ?? PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(
                  pdfImage,
                  fit: pw.BoxFit.contain,
                ),
              );
            },
          ),
        );
      }

      // Get directory to save PDF
      final directory = await _getDocumentsDirectory();
      final filePath = path.join(directory.path, fileName);

      // Save PDF
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      throw Exception('Failed to generate PDF: ${e.toString()}');
    }
  }

  /// Compress an existing PDF
  Future<String> compressPdf(String pdfPath, {int quality = 70}) async {
    // Note: PDF compression is complex and may require native libraries
    // For now, we'll just return the original path
    // In production, consider using plugins like flutter_native_pdf_compressor
    return pdfPath;
  }

  /// Get the size of a PDF file in bytes
  Future<int> getPdfSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Delete a PDF file
  Future<void> deletePdf(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete PDF: ${e.toString()}');
    }
  }

  /// Check if a PDF file exists
  Future<bool> pdfExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get the documents directory for storing PDFs
  Future<Directory> _getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDirectory = Directory(path.join(directory.path, 'pdfs'));

    if (!await pdfDirectory.exists()) {
      await pdfDirectory.create(recursive: true);
    }

    return pdfDirectory;
  }

  /// Get all PDF files in the documents directory
  Future<List<FileSystemEntity>> getAllPdfs() async {
    try {
      final directory = await _getDocumentsDirectory();
      final files = directory.listSync();
      return files.where((file) => file.path.endsWith('.pdf')).toList();
    } catch (e) {
      return [];
    }
  }

  /// Generate a unique filename for a PDF
  String generateFileName({String? baseName}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final base = baseName?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') ?? 'document';
    return '${base}_$timestamp.pdf';
  }

  /// Validate PDF file size against limits
  bool isFileSizeValid(int sizeBytes) {
    final maxSizeBytes = AppConstants.maxPdfSizeMB * 1024 * 1024;
    return sizeBytes <= maxSizeBytes;
  }
}
