/// Production API configuration — injected at build time via --dart-define.
///
/// Example release build:
/// ```bash
/// flutter build apk --release \
///   --dart-define=API_BASE_URL=https://your-app.up.railway.app/api/v1
/// ```
class AppConfig {
  AppConfig._();

  /// HTTPS API base URL including /api/v1 prefix. No localhost.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://YOUR_RAILWAY_APP.up.railway.app/api/v1',
  );

  static const int connectTimeoutSeconds = 20;
  static const int receiveTimeoutSeconds = 20;
  static const int maxRetryAttempts = 3;

  static void assertProductionUrl() {
    assert(
      !apiBaseUrl.contains('localhost') &&
          !apiBaseUrl.contains('127.0.0.1') &&
          !apiBaseUrl.contains('10.0.2.2'),
      'API_BASE_URL must be a public HTTPS URL for device builds.',
    );
  }
}
