import 'package:flow_desk/core/config/app_config.dart';

/// API and App configuration constants for FlowDesk
class AppConstants {
  AppConstants._();

  /// Online API base URL (Railway / production)
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Token storage keys (flutter_secure_storage)
  static const String accessTokenKey = 'flowdesk_access_token';
  static const String refreshTokenKey = 'flowdesk_refresh_token';

  // Pagination
  static const int defaultPageLimit = 50;

  // App info
  static const String appName = 'FlowDesk';
  static const String appTagline = 'Get things done, beautifully.';
}
