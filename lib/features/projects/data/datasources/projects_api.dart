import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

final projectsApiProvider = Provider<ProjectsApi>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ProjectsApi(dio);
});

/// API client for project management
class ProjectsApi {
  final Dio _dio;

  ProjectsApi(this._dio);

  /// Get all projects
  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final response = await _dio.get(ApiEndpoints.projects);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      } else {
        throw Exception('Failed to get projects: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        'Network error: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('Failed to get projects: $e');
    }
  }

  /// Get project by ID
  Future<Map<String, dynamic>> getProject(String id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.projects}/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is Map) {
          return data['data'] as Map<String, dynamic>;
        } else if (data is Map) {
          return data as Map<String, dynamic>;
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to get project: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get project: $e');
    }
  }

  /// Create new project
  Future<Map<String, dynamic>> createProject({
    required String name,
    String? description,
    String? color,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.projects,
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (color != null) 'color': color,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data['data'] is Map) {
          return data['data'] as Map<String, dynamic>;
        } else if (data is Map) {
          return data as Map<String, dynamic>;
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to create project: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  /// Update project
  Future<Map<String, dynamic>> updateProject({
    required String id,
    String? name,
    String? description,
    String? color,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.projects}/$id',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (color != null) 'color': color,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is Map) {
          return data['data'] as Map<String, dynamic>;
        } else if (data is Map) {
          return data as Map<String, dynamic>;
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to update project: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  /// Delete project
  Future<void> deleteProject(String id) async {
    try {
      final response = await _dio.delete('${ApiEndpoints.projects}/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete project: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }
}
