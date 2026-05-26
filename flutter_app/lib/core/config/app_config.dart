import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API configuration loaded from `flutter_app/.env` at startup.
class AppConfig {
  AppConfig._();

  static const String _apiBaseUrlKey = 'API_BASE_URL';

  static const int connectTimeoutSeconds = 20;
  static const int receiveTimeoutSeconds = 20;
  static const int maxRetryAttempts = 3;

  /// HTTPS API base URL including `/api/v1` — from `.env`.
  static String get apiBaseUrl {
    final url = dotenv.env[_apiBaseUrlKey]?.trim();
    if (url == null || url.isEmpty) {
      throw StateError(
        '$_apiBaseUrlKey is missing. Copy .env.example to .env and set your Railway URL.',
      );
    }
    return url;
  }

  /// Release builds must target the hosted HTTPS API.
  static void assertProductionUrl() {
    assert(
      apiBaseUrl.startsWith('https://'),
      'API_BASE_URL in .env must be an HTTPS URL (your Railway deployment).',
    );
  }
}
