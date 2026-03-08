import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl + AppConstants.apiVersion,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add auth interceptor with token refresh
  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = ref.read(secureStorageServiceProvider);
        final token = await storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          try {
            final storage = ref.read(secureStorageServiceProvider);
            final refreshToken = await storage.getRefreshToken();

            if (refreshToken != null) {
              // Create a new Dio instance to avoid interceptor loop
              final refreshDio = Dio(
                BaseOptions(
                  baseUrl: AppConstants.baseUrl + AppConstants.apiVersion,
                ),
              );

              // Attempt token refresh
              final response = await refreshDio.post(
                '/auth/refresh',
                data: {'refresh_token': refreshToken},
              );

              if (response.statusCode == 200) {
                final data = response.data;
                final newAccessToken = data['access_token'];
                final newRefreshToken = data['refresh_token'];

                // Save new tokens
                await storage.saveAccessToken(newAccessToken);
                if (newRefreshToken != null) {
                  await storage.saveRefreshToken(newRefreshToken);
                }

                // Retry the original request with new token
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccessToken';

                final retryResponse = await dio.fetch(opts);
                return handler.resolve(retryResponse);
              }
            }
          } catch (e) {
            // Refresh failed, clear tokens and let error propagate
            final storage = ref.read(secureStorageServiceProvider);
            await storage.deleteAccessToken();
            await storage.deleteRefreshToken();
          }
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});

// Separate client provider for cases where we need a Dio without interceptors
final dioClientProvider = Provider<Dio>((ref) => ref.watch(dioProvider));
