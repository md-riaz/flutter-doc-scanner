/// Domain entity representing a project/folder for organizing documents
class Project {
  final String id;
  final String name;
  final String? description;
  final String? color; // Hex color code for visual distinction
  final int documentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Project({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.documentCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    int? documentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      documentCount: documentCount ?? this.documentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'document_count': documentCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
      documentCount: json['document_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
