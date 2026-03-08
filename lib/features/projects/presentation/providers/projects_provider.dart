import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/project.dart';
import '../../data/repositories/projects_repository.dart';

/// Provider for projects state
final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  final repository = ref.watch(projectsRepositoryProvider);
  return ProjectsNotifier(repository: repository);
});

/// State for projects
class ProjectsState {
  final List<Project> projects;
  final bool isLoading;
  final String? error;
  final Project? selectedProject;

  const ProjectsState({
    this.projects = const [],
    this.isLoading = false,
    this.error,
    this.selectedProject,
  });

  ProjectsState copyWith({
    List<Project>? projects,
    bool? isLoading,
    String? error,
    Project? selectedProject,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedProject: selectedProject ?? this.selectedProject,
    );
  }

  /// Total document count across all projects
  int get totalDocuments =>
      projects.fold(0, (sum, project) => sum + project.documentCount);
}

/// Notifier for managing projects
class ProjectsNotifier extends StateNotifier<ProjectsState> {
  final ProjectsRepository repository;

  ProjectsNotifier({required this.repository}) : super(const ProjectsState()) {
    loadProjects();
  }

  /// Load all projects
  Future<void> loadProjects() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final projects = await repository.getProjects();

      state = state.copyWith(
        projects: projects,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load projects: $e',
      );
    }
  }

  /// Get project by ID
  Future<void> selectProject(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final project = await repository.getProject(id);

      state = state.copyWith(
        selectedProject: project,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load project: $e',
      );
    }
  }

  /// Clear selected project
  void clearSelection() {
    state = state.copyWith(selectedProject: null);
  }

  /// Create new project
  Future<void> createProject({
    required String name,
    String? description,
    String? color,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final newProject = await repository.createProject(
        name: name,
        description: description,
        color: color,
      );

      state = state.copyWith(
        projects: [...state.projects, newProject],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create project: $e',
      );
    }
  }

  /// Update project
  Future<void> updateProject({
    required String id,
    String? name,
    String? description,
    String? color,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updatedProject = await repository.updateProject(
        id: id,
        name: name,
        description: description,
        color: color,
      );

      final updatedProjects = state.projects.map((project) {
        if (project.id == id) {
          return updatedProject;
        }
        return project;
      }).toList();

      state = state.copyWith(
        projects: updatedProjects,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update project: $e',
      );
    }
  }

  /// Delete project
  Future<void> deleteProject(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await repository.deleteProject(id);

      final updatedProjects =
          state.projects.where((project) => project.id != id).toList();

      state = state.copyWith(
        projects: updatedProjects,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete project: $e',
      );
    }
  }

  /// Refresh projects
  Future<void> refresh() async {
    await loadProjects();
  }
}
