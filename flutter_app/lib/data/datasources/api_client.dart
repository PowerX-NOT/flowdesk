import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flow_desk/core/constants/app_constants.dart';
import 'package:flow_desk/core/errors/failures.dart';

/// Dio HTTP client with JWT Bearer token injection and error mapping.
/// Tokens stored in flutter_secure_storage (Keychain/Keystore) — NOT SharedPreferences.
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Do NOT follow redirects automatically for auth endpoints
        followRedirects: false,
      ),
    );

    _dio.interceptors.add(_AuthInterceptor(_secureStorage));
    _dio.interceptors.add(_ErrorInterceptor());
  }

  Dio get dio => _dio;
}

/// Injects JWT Bearer token from secure storage into every request
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  _AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Read token from secure storage — NOT localStorage or SharedPreferences
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Maps Dio exceptions to domain Failure types — generic messages to UI
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Do NOT log token or request body — may contain credentials
    final failure = _mapError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: failure,
        message: failure.message,
        type: err.type,
        response: err.response,
      ),
    );
  }

  Failure _mapError(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    final statusCode = err.response?.statusCode;
    final data = err.response?.data;
    // Extract backend detail message — generic fallback if not available
    final detail = data is Map ? data['detail']?.toString() : null;

    switch (statusCode) {
      case 401:
        return const UnauthorizedFailure();
      case 403:
        return const AuthFailure('You do not have permission to do this.');
      case 404:
        return const NotFoundFailure();
      case 409:
        return ServerFailure(detail ?? 'Conflict.', statusCode: statusCode);
      case 422:
        return const ValidationFailure('Invalid request data.');
      case 429:
        return const ServerFailure('Too many requests. Please slow down.');
      default:
        if (statusCode != null && statusCode >= 500) {
          // Do NOT expose server internals
          return const ServerFailure('Server error. Please try again later.');
        }
        return ServerFailure(detail ?? 'An error occurred.', statusCode: statusCode);
    }
  }
}

/// Extension to extract Failure from DioException
extension DioFailure on DioException {
  Failure get failure => error is Failure ? error as Failure : const UnknownFailure();
}
