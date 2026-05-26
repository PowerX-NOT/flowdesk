/// API and App configuration constants for FlowDesk
class AppConstants {
  AppConstants._();

  // Base URL — change to your server address for production
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // Token storage keys (flutter_secure_storage)
  static const String accessTokenKey = 'flowdesk_access_token';

  // Pagination
  static const int defaultPageLimit = 50;

  // App info
  static const String appName = 'FlowDesk';
  static const String appTagline = 'Get things done, beautifully.';
}
