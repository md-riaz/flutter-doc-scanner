import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/mock_projects_api.dart';
import '../../domain/entities/project.dart';
import '../datasources/projects_api.dart';

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  final projectsApi = ref.watch(projectsApiProvider);
  return ProjectsRepository(projectsApi);
});

/// Repository for managing projects
class ProjectsRepository {
  final ProjectsApi? _projectsApi;
  final MockProjectsApi _mockProjectsApi = MockProjectsApi();

  ProjectsRepository(this._projectsApi);

  /// Get all projects
  Future<List<Project>> getProjects() async {
    try {
      List<Map<String, dynamic>> projectsData;

      if (AppConstants.useMockApi) {
        projectsData = await _mockProjectsApi.getProjects();
      } else {
        if (_projectsApi == null) {
          throw Exception('Projects API not configured');
        }
        projectsData = await _projectsApi.getProjects();
      }

      return projectsData.map((data) => Project.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get projects: $e');
    }
  }

  /// Get project by ID
  Future<Project> getProject(String id) async {
    try {
      Map<String, dynamic> projectData;

      if (AppConstants.useMockApi) {
        projectData = await _mockProjectsApi.getProject(id);
      } else {
        if (_projectsApi == null) {
          throw Exception('Projects API not configured');
        }
        projectData = await _projectsApi.getProject(id);
      }

      return Project.fromJson(projectData);
    } catch (e) {
      throw Exception('Failed to get project: $e');
    }
  }

  /// Create new project
  Future<Project> createProject({
    required String name,
    String? description,
    String? color,
  }) async {
    try {
      Map<String, dynamic> projectData;

      if (AppConstants.useMockApi) {
        projectData = await _mockProjectsApi.createProject(
          name: name,
          description: description,
          color: color,
        );
      } else {
        if (_projectsApi == null) {
          throw Exception('Projects API not configured');
        }
        projectData = await _projectsApi.createProject(
          name: name,
          description: description,
          color: color,
        );
      }

      return Project.fromJson(projectData);
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  /// Update project
  Future<Project> updateProject({
    required String id,
    String? name,
    String? description,
    String? color,
  }) async {
    try {
      Map<String, dynamic> projectData;

      if (AppConstants.useMockApi) {
        projectData = await _mockProjectsApi.updateProject(
          id: id,
          name: name,
          description: description,
          color: color,
        );
      } else {
        if (_projectsApi == null) {
          throw Exception('Projects API not configured');
        }
        projectData = await _projectsApi.updateProject(
          id: id,
          name: name,
          description: description,
          color: color,
        );
      }

      return Project.fromJson(projectData);
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  /// Delete project
  Future<void> deleteProject(String id) async {
    try {
      if (AppConstants.useMockApi) {
        await _mockProjectsApi.deleteProject(id);
      } else {
        if (_projectsApi == null) {
          throw Exception('Projects API not configured');
        }
        await _projectsApi.deleteProject(id);
      }
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }
}
