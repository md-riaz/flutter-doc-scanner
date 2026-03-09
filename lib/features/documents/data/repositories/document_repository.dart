import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'dart:convert';
import '../../../../core/database/app_database.dart';
import '../../../pdf/domain/entities/pdf_document.dart' as pdf_entity;

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DocumentRepository(database);
});

/// Repository for managing documents in the local database
class DocumentRepository {
  final AppDatabase _database;

  DocumentRepository(this._database);

  /// Save a PDF document to the database
  Future<void> saveDocument(pdf_entity.PdfDocument document) async {
    await _database.insertDocument(
      DocumentsCompanion.insert(
        id: document.id,
        title: document.title,
        filePath: document.filePath,
        pageCount: document.pageCount,
        fileSizeBytes: document.fileSizeBytes,
        createdAt: document.createdAt,
        projectId: Value(document.projectId),
        category: Value(document.category),
        tags: Value(document.tags.isNotEmpty ? jsonEncode(document.tags) : null),
        uploadStatus: const Value('pending'),
        isUploaded: const Value(false),
      ),
    );
  }

  /// Get all documents
  Future<List<pdf_entity.PdfDocument>> getAllDocuments() async {
    final docs = await _database.getAllDocuments();
    return docs.map(_mapToPdfDocument).toList();
  }

  /// Get a document by ID
  Future<pdf_entity.PdfDocument?> getDocumentById(String id) async {
    final doc = await _database.getDocumentById(id);
    return doc != null ? _mapToPdfDocument(doc) : null;
  }

  /// Get documents by project
  Future<List<pdf_entity.PdfDocument>> getDocumentsByProject(
      String projectId) async {
    final docs = await _database.getDocumentsByProject(projectId);
    return docs.map(_mapToPdfDocument).toList();
  }

  /// Get pending uploads
  Future<List<pdf_entity.PdfDocument>> getPendingUploads() async {
    final docs = await _database.getPendingUploads();
    return docs.map(_mapToPdfDocument).toList();
  }

  /// Update document
  Future<void> updateDocument(pdf_entity.PdfDocument document) async {
    await _database.updateDocument(
      DocumentsCompanion(
        id: Value(document.id),
        title: Value(document.title),
        filePath: Value(document.filePath),
        pageCount: Value(document.pageCount),
        fileSizeBytes: Value(document.fileSizeBytes),
        createdAt: Value(document.createdAt),
        updatedAt: Value(DateTime.now()),
        projectId: Value(document.projectId),
        category: Value(document.category),
        tags: Value(document.tags.isNotEmpty ? jsonEncode(document.tags) : null),
      ),
    );
  }

  /// Mark document as uploaded
  Future<void> markAsUploaded(String documentId) async {
    final doc = await _database.getDocumentById(documentId);
    if (doc != null) {
      await _database.updateDocument(
        doc.toCompanion(true).copyWith(
          isUploaded: const Value(true),
          uploadStatus: const Value('uploaded'),
          uploadedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  /// Delete document
  Future<void> deleteDocument(String id) async {
    await _database.deleteDocument(id);
  }

  /// Search documents by title or tags
  Future<List<pdf_entity.PdfDocument>> searchDocuments(String query) async {
    final allDocs = await _database.getAllDocuments();
    final filtered = allDocs.where((doc) {
      final titleMatch =
          doc.title.toLowerCase().contains(query.toLowerCase());
      final tagsMatch = doc.tags != null &&
          doc.tags!.toLowerCase().contains(query.toLowerCase());
      return titleMatch || tagsMatch;
    }).toList();
    return filtered.map(_mapToPdfDocument).toList();
  }

  /// Map database document to PDF document entity
  pdf_entity.PdfDocument _mapToPdfDocument(Document doc) {
    List<String> tags = [];
    if (doc.tags != null) {
      try {
        tags = List<String>.from(jsonDecode(doc.tags!));
      } catch (e) {
        // Ignore parsing errors
      }
    }

    return pdf_entity.PdfDocument(
      id: doc.id,
      title: doc.title,
      filePath: doc.filePath,
      pageCount: doc.pageCount,
      fileSizeBytes: doc.fileSizeBytes,
      createdAt: doc.createdAt,
      projectId: doc.projectId,
      tags: tags,
      category: doc.category,
    );
  }
}
