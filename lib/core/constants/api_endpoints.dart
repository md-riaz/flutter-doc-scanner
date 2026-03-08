class ApiEndpoints {
  // Authentication
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/me';

  // Metadata
  static const String projects = '/projects';
  static const String folders = '/folders';
  static const String categories = '/categories';
  static const String tags = '/tags';

  // Documents
  static const String documents = '/documents';
  static const String documentUpload = '/documents/upload';

  static String documentDetail(String id) => '/documents/$id';
  static String documentMetadata(String id) => '/documents/$id/metadata';
  static String documentDownload(String id) => '/documents/$id/download';

  // Admin
  static const String adminUploads = '/admin/uploads';
  static const String adminUsers = '/admin/users';
  static const String adminReports = '/admin/reports';
  static const String adminFailedUploads = '/admin/failed-uploads';
}
