import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/document_repository.dart';
import '../../../pdf/domain/entities/pdf_document.dart';

// State for documents list
class DocumentsState {
  final List<PdfDocument> documents;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final String? activeProjectId;

  const DocumentsState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.activeProjectId,
  });

  DocumentsState copyWith({
    List<PdfDocument>? documents,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? activeProjectId,
  }) {
    return DocumentsState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      activeProjectId: activeProjectId ?? this.activeProjectId,
    );
  }

  List<PdfDocument> get filteredDocuments {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return documents;
    }
    return documents.where((doc) {
      return doc.title.toLowerCase().contains(searchQuery!.toLowerCase()) ||
          doc.tags.any((tag) => tag.toLowerCase().contains(searchQuery!.toLowerCase()));
    }).toList();
  }
}

// Provider for documents
final documentsProvider =
    StateNotifierProvider<DocumentsNotifier, DocumentsState>((ref) {
  final documentRepository = ref.watch(documentRepositoryProvider);
  return DocumentsNotifier(documentRepository);
});

class DocumentsNotifier extends StateNotifier<DocumentsState> {
  final DocumentRepository _documentRepository;

  DocumentsNotifier(this._documentRepository) : super(const DocumentsState()) {
    loadDocuments();
  }

  /// Load all documents
  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final documents = await _documentRepository.getAllDocuments();
      state = state.copyWith(
        documents: documents,
        isLoading: false,
        activeProjectId: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Search documents
  Future<void> searchDocuments(String query) async {
    state = state.copyWith(
      searchQuery: query,
      error: null,
    );
  }

  /// Delete a document
  Future<void> deleteDocument(String id) async {
    try {
      await _documentRepository.deleteDocument(id);
      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update existing document metadata
  Future<void> updateDocumentMetadata({
    required String id,
    required String title,
    String? category,
    required List<String> tags,
  }) async {
    try {
      final document = await _documentRepository.getDocumentById(id);
      if (document == null) {
        throw Exception('Document not found');
      }

      await _documentRepository.updateDocument(
        document.copyWith(
          title: title,
          category: category,
          tags: tags,
        ),
      );

      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Get documents by project
  Future<void> loadDocumentsByProject(String projectId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final documents =
          await _documentRepository.getDocumentsByProject(projectId);
      state = state.copyWith(
        documents: documents,
        isLoading: false,
        activeProjectId: projectId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh documents list
  Future<void> refresh() async {
    if (state.activeProjectId != null) {
      await loadDocumentsByProject(state.activeProjectId!);
      return;
    }
    await loadDocuments();
  }
}
