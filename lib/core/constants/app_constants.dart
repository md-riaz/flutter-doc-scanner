class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/api/v1';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';

  // Upload Status
  static const String uploadStatusPending = 'pending';
  static const String uploadStatusUploading = 'uploading';
  static const String uploadStatusUploaded = 'uploaded';
  static const String uploadStatusFailed = 'failed';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';
  static const String roleViewer = 'viewer';

  // File Settings
  static const int maxPdfSizeMB = 50;
  static const int imageCompressionQuality = 85;

  // Retry Settings
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 5);
}
