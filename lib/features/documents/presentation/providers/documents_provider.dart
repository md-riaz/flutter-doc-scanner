import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/document_repository.dart';
import '../../../pdf/domain/entities/pdf_document.dart';

// State for documents list
class DocumentsState {
  final List<PdfDocument> documents;
  final bool isLoading;
  final String? error;
  final String? searchQuery;

  const DocumentsState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
  });

  DocumentsState copyWith({
    List<PdfDocument>? documents,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return DocumentsState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
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
    state = state.copyWith(searchQuery: query);
    if (query.isEmpty) {
      await loadDocuments();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final documents = await _documentRepository.searchDocuments(query);
      state = state.copyWith(
        documents: documents,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String id) async {
    try {
      await _documentRepository.deleteDocument(id);
      await loadDocuments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
    await loadDocuments();
  }
}
