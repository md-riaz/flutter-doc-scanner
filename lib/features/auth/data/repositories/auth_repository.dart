import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';
import '../datasources/auth_api.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/mock_auth_api.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApi = ref.watch(authApiProvider);
  final mockAuthApi = ref.watch(mockAuthApiProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthRepository(authApi, mockAuthApi, storage);
});

class AuthRepository {
  final AuthApi _authApi;
  final MockAuthApi _mockAuthApi;
  final SecureStorageService _storage;

  AuthRepository(this._authApi, this._mockAuthApi, this._storage);

  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      // Use mock API if configured, otherwise use real API
      final response = AppConstants.useMockApi
          ? await _mockAuthApi.login(
              username: username,
              password: password,
            )
          : await _authApi.login(
              username: username,
              password: password,
            );

      final accessToken = response['access_token'] ?? response['accessToken'];
      final refreshToken = response['refresh_token'] ?? response['refreshToken'];
      final userData = response['user'] ?? response['data'];

      if (accessToken == null || userData == null) {
        throw AuthException(message: 'Invalid response from server');
      }

      await _storage.saveAccessToken(accessToken);
      if (refreshToken != null) {
        await _storage.saveRefreshToken(refreshToken);
      }

      final user = User.fromJson(userData);
      await _storage.saveUser(jsonEncode(user.toJson()));

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException(message: 'Invalid username or password');
      }
      throw NetworkException(
        message: e.message ?? 'Network error occurred',
      );
    } catch (e) {
      throw AuthException(message: 'Login failed: ${e.toString()}');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final userJson = await _storage.getUser();
      if (userJson == null) return null;

      final userData = jsonDecode(userJson);
      return User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    return token != null;
  }

  Future<void> logout() async {
    try {
      if (AppConstants.useMockApi) {
        await _mockAuthApi.logout();
      } else {
        await _authApi.logout();
      }
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      await _storage.clearAll();
    }
  }

  Future<void> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException(message: 'No refresh token available');
      }

      final response = AppConstants.useMockApi
          ? await _mockAuthApi.refreshToken(refreshToken)
          : await _authApi.refreshToken(refreshToken);
      final accessToken = response['access_token'] ?? response['accessToken'];

      if (accessToken == null) {
        throw AuthException(message: 'Failed to refresh token');
      }

      await _storage.saveAccessToken(accessToken);
    } catch (e) {
      await logout();
      rethrow;
    }
  }
}
