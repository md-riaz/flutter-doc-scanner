import 'scanned_page.dart';

/// Represents a scanning session with multiple pages
class ScanSession {
  final String id;
  final List<ScannedPage> pages;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? projectId;
  final String? title;

  const ScanSession({
    required this.id,
    required this.pages,
    required this.createdAt,
    this.updatedAt,
    this.projectId,
    this.title,
  });

  ScanSession copyWith({
    String? id,
    List<ScannedPage>? pages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? projectId,
    String? title,
  }) {
    return ScanSession(
      id: id ?? this.id,
      pages: pages ?? this.pages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
    );
  }

  int get pageCount => pages.length;

  bool get isEmpty => pages.isEmpty;

  bool get isNotEmpty => pages.isNotEmpty;
}
