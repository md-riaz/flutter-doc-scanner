/// Mock API client for project management (for testing without backend)
class MockProjectsApi {
  // Mock data storage
  static final List<Map<String, dynamic>> _mockProjects = [
    {
      'id': 'project_001',
      'name': 'Personal Documents',
      'description': 'Personal identification and important documents',
      'color': '#2196F3',
      'document_count': 5,
      'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': 'project_002',
      'name': 'Work Documents',
      'description': 'Work-related contracts and agreements',
      'color': '#4CAF50',
      'document_count': 12,
      'created_at': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': 'project_003',
      'name': 'Financial Records',
      'description': 'Bills, receipts, and financial statements',
      'color': '#FF9800',
      'document_count': 8,
      'created_at': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    },
    {
      'id': 'project_004',
      'name': 'Legal Documents',
      'description': 'Legal contracts and court documents',
      'color': '#9C27B0',
      'document_count': 3,
      'created_at': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    },
  ];

  /// Simulate API delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Mock get all projects
  Future<List<Map<String, dynamic>>> getProjects() async {
    await _simulateDelay();
    return List<Map<String, dynamic>>.from(_mockProjects);
  }

  /// Mock get project by ID
  Future<Map<String, dynamic>> getProject(String id) async {
    await _simulateDelay();

    final project = _mockProjects.firstWhere(
      (p) => p['id'] == id,
      orElse: () => throw Exception('Project not found'),
    );

    return Map<String, dynamic>.from(project);
  }

  /// Mock create project
  Future<Map<String, dynamic>> createProject({
    required String name,
    String? description,
    String? color,
  }) async {
    await _simulateDelay();

    final newProject = {
      'id': 'project_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'description': description,
      'color': color ?? '#607D8B',
      'document_count': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    _mockProjects.add(newProject);
    return Map<String, dynamic>.from(newProject);
  }

  /// Mock update project
  Future<Map<String, dynamic>> updateProject({
    required String id,
    String? name,
    String? description,
    String? color,
  }) async {
    await _simulateDelay();

    final index = _mockProjects.indexWhere((p) => p['id'] == id);
    if (index == -1) {
      throw Exception('Project not found');
    }

    final project = Map<String, dynamic>.from(_mockProjects[index]);

    if (name != null) project['name'] = name;
    if (description != null) project['description'] = description;
    if (color != null) project['color'] = color;
    project['updated_at'] = DateTime.now().toIso8601String();

    _mockProjects[index] = project;
    return project;
  }

  /// Mock delete project
  Future<void> deleteProject(String id) async {
    await _simulateDelay();

    final index = _mockProjects.indexWhere((p) => p['id'] == id);
    if (index == -1) {
      throw Exception('Project not found');
    }

    _mockProjects.removeAt(index);
  }
}
