import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scanned_page.dart';
import '../../domain/entities/scan_session.dart';
import '../../data/repositories/scan_repository.dart';
import '../../data/services/camera_service.dart';

// State class for scan session
class ScanSessionState {
  final ScanSession? session;
  final bool isLoading;
  final String? error;
  final bool isCameraInitialized;

  const ScanSessionState({
    this.session,
    this.isLoading = false,
    this.error,
    this.isCameraInitialized = false,
  });

  ScanSessionState copyWith({
    ScanSession? session,
    bool? isLoading,
    String? error,
    bool? isCameraInitialized,
  }) {
    return ScanSessionState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
    );
  }
}

// Provider for scan session
final scanSessionProvider =
    StateNotifierProvider<ScanSessionNotifier, ScanSessionState>((ref) {
  final scanRepository = ref.watch(scanRepositoryProvider);
  final cameraService = ref.watch(cameraServiceProvider);
  return ScanSessionNotifier(scanRepository, cameraService);
});

class ScanSessionNotifier extends StateNotifier<ScanSessionState> {
  final ScanRepository _scanRepository;
  final CameraService _cameraService;

  ScanSessionNotifier(this._scanRepository, this._cameraService)
      : super(const ScanSessionState());

  /// Initialize camera
  Future<void> initializeCamera() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _cameraService.initialize();
      state = state.copyWith(
        isLoading: false,
        isCameraInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isCameraInitialized: false,
      );
    }
  }

  /// Start a new scan session
  void startSession({String? projectId, String? title}) {
    final session = _scanRepository.createSession(
      projectId: projectId,
      title: title,
    );
    state = state.copyWith(session: session, error: null);
  }

  /// Capture a new page
  Future<void> capturePage() async {
    if (state.session == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final pageNumber = state.session!.pages.length + 1;
      final page = await _scanRepository.capturePage(pageNumber);

      final updatedSession = state.session!.copyWith(
        pages: [...state.session!.pages, page],
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        session: updatedSession,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to capture page: ${e.toString()}',
      );
    }
  }

  /// Add an image from gallery
  Future<void> addImageFromGallery(List<int> imageBytes) async {
    // Create a session if one doesn't exist
    if (state.session == null) {
      startSession();
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final pageNumber = state.session!.pages.length + 1;
      final page = await _scanRepository.createPageFromBytes(imageBytes, pageNumber);

      final updatedSession = state.session!.copyWith(
        pages: [...state.session!.pages, page],
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        session: updatedSession,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add image: ${e.toString()}',
      );
    }
  }

  /// Process a page (crop and enhance)
  Future<void> processPage(
    String pageId, {
    List<Offset>? corners,
    bool autoEnhance = true,
  }) async {
    if (state.session == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final pageIndex = state.session!.pages.indexWhere((p) => p.id == pageId);
      if (pageIndex == -1) {
        throw Exception('Page not found');
      }

      final page = state.session!.pages[pageIndex];
      final processedPage = await _scanRepository.processPage(
        page,
        corners: corners,
        autoEnhance: autoEnhance,
      );

      final updatedPages = [...state.session!.pages];
      updatedPages[pageIndex] = processedPage;

      final updatedSession = state.session!.copyWith(
        pages: updatedPages,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        session: updatedSession,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to process page: ${e.toString()}',
      );
    }
  }

  /// Remove a page from the session
  void removePage(String pageId) {
    if (state.session == null) return;

    final updatedPages = state.session!.pages.where((p) => p.id != pageId).toList();

    // Update page numbers
    final renumberedPages = updatedPages.asMap().entries.map((entry) {
      return entry.value.copyWith(pageNumber: entry.key + 1);
    }).toList();

    final updatedSession = state.session!.copyWith(
      pages: renumberedPages,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(session: updatedSession);
  }

  /// Reorder pages
  void reorderPages(int oldIndex, int newIndex) {
    if (state.session == null) return;

    final pages = [...state.session!.pages];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final page = pages.removeAt(oldIndex);
    pages.insert(newIndex, page);

    // Update page numbers
    final renumberedPages = pages.asMap().entries.map((entry) {
      return entry.value.copyWith(pageNumber: entry.key + 1);
    }).toList();

    final updatedSession = state.session!.copyWith(
      pages: renumberedPages,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(session: updatedSession);
  }

  /// Clear the current session
  void clearSession() {
    state = const ScanSessionState();
  }

  /// Dispose camera resources
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}
