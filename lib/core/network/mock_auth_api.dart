import 'package:flutter_riverpod/flutter_riverpod.dart';

final mockAuthApiProvider = Provider<MockAuthApi>((ref) {
  return MockAuthApi();
});

/// Mock implementation of authentication API for development without backend
class MockAuthApi {
  // Mock user database
  final Map<String, Map<String, dynamic>> _mockUsers = {
    'admin': {
      'username': 'admin',
      'password': 'admin123',
      'user': {
        'id': '1',
        'name': 'Admin User',
        'username': 'admin',
        'email': 'admin@example.com',
        'role': 'admin',
        'assignedProjects': ['project-1', 'project-2', 'project-3'],
      },
    },
    'user': {
      'username': 'user',
      'password': 'user123',
      'user': {
        'id': '2',
        'name': 'Regular User',
        'username': 'user',
        'email': 'user@example.com',
        'role': 'user',
        'assignedProjects': ['project-1', 'project-2'],
      },
    },
    'viewer': {
      'username': 'viewer',
      'password': 'viewer123',
      'user': {
        'id': '3',
        'name': 'Viewer User',
        'username': 'viewer',
        'email': 'viewer@example.com',
        'role': 'viewer',
        'assignedProjects': ['project-1'],
      },
    },
  };

  /// Mock login - returns user data if credentials match
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final mockUser = _mockUsers[username.toLowerCase()];

    if (mockUser == null || mockUser['password'] != password) {
      throw Exception('Invalid username or password');
    }

    return {
      'access_token': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      'refresh_token': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': mockUser['user'],
    };
  }

  /// Mock token refresh
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'access_token': 'mock_access_token_refreshed_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  /// Mock logout - always succeeds
  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock logout always succeeds
  }

  /// Mock get current user
  Future<Map<String, dynamic>> getMe() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock user data (would normally be based on token)
    return {
      'id': '1',
      'name': 'Mock User',
      'username': 'mockuser',
      'email': 'mock@example.com',
      'role': 'user',
      'assignedProjects': ['project-1'],
    };
  }
}
