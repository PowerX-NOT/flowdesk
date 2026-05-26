/// Production API configuration — injected at build time via --dart-define.
///
/// ```bash
/// flutter build apk --release \
///   --dart-define=API_BASE_URL=https://your-app.up.railway.app/api/v1
/// ```
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://YOUR_RAILWAY_APP.up.railway.app/api/v1',
  );

  static const int connectTimeoutSeconds = 20;
  static const int receiveTimeoutSeconds = 20;
  static const int maxRetryAttempts = 3;

  /// Release builds must target the hosted HTTPS API.
  static void assertProductionUrl() {
    assert(
      apiBaseUrl.startsWith('https://'),
      'API_BASE_URL must be an HTTPS URL (your Railway deployment).',
    );
  }
}
