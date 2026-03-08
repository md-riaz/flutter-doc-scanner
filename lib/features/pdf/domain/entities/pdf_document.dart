import 'package:flutter/material.dart';

/// Represents a generated PDF document
class PdfDocument {
  final String id;
  final String title;
  final String filePath;
  final int pageCount;
  final int fileSizeBytes;
  final DateTime createdAt;
  final String? projectId;
  final List<String> tags;
  final String? category;

  const PdfDocument({
    required this.id,
    required this.title,
    required this.filePath,
    required this.pageCount,
    required this.fileSizeBytes,
    required this.createdAt,
    this.projectId,
    this.tags = const [],
    this.category,
  });

  PdfDocument copyWith({
    String? id,
    String? title,
    String? filePath,
    int? pageCount,
    int? fileSizeBytes,
    DateTime? createdAt,
    String? projectId,
    List<String>? tags,
    String? category,
  }) {
    return PdfDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      pageCount: pageCount ?? this.pageCount,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      projectId: projectId ?? this.projectId,
      tags: tags ?? this.tags,
      category: category ?? this.category,
    );
  }

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'pageCount': pageCount,
      'fileSizeBytes': fileSizeBytes,
      'createdAt': createdAt.toIso8601String(),
      'projectId': projectId,
      'tags': tags,
      'category': category,
    };
  }

  factory PdfDocument.fromJson(Map<String, dynamic> json) {
    return PdfDocument(
      id: json['id'],
      title: json['title'],
      filePath: json['filePath'],
      pageCount: json['pageCount'],
      fileSizeBytes: json['fileSizeBytes'],
      createdAt: DateTime.parse(json['createdAt']),
      projectId: json['projectId'],
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
    );
  }
}
