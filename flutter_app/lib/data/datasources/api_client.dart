import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flow_desk/core/config/app_config.dart';
import 'package:flow_desk/core/constants/app_constants.dart';
import 'package:flow_desk/core/errors/failures.dart';

typedef UnauthorizedCallback = Future<void> Function();

/// Dio HTTP client with JWT injection, retries, and expired-token handling.
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  UnauthorizedCallback? onUnauthorized;

  ApiClient(this._secureStorage) {
    if (kReleaseMode) {
      AppConfig.assertProductionUrl();
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConfig.receiveTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        followRedirects: false,
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_secureStorage, _handleUnauthorized),
      _RetryInterceptor(_dio),
      _ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  Future<void> _handleUnauthorized() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    await onUnauthorized?.call();
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Future<void> Function() _onUnauthorized;

  _AuthInterceptor(this._secureStorage, this._onUnauthorized);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/login') &&
        !err.requestOptions.path.contains('/auth/register') &&
        !err.requestOptions.path.contains('/auth/refresh')) {
      await _onUnauthorized();
    }
    handler.next(err);
  }
}

/// Retries transient network failures with exponential backoff.
class _RetryInterceptor extends Interceptor {
  final Dio _dio;

  _RetryInterceptor(this._dio);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final shouldRetry = _isRetryable(err) &&
        err.requestOptions.extra['retryCount'] == null;

    if (!shouldRetry) {
      handler.next(err);
      return;
    }

    var attempt = 0;
    while (attempt < AppConfig.maxRetryAttempts) {
      attempt++;
      await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
      try {
        err.requestOptions.extra['retryCount'] = attempt;
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } on DioException catch (retryErr) {
        if (!_isRetryable(retryErr) || attempt >= AppConfig.maxRetryAttempts) {
          handler.next(retryErr);
          return;
        }
      }
    }
    handler.next(err);
  }

  bool _isRetryable(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
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
          final message =
              detail ?? 'Server error (HTTP $statusCode). Please try again later.';
          return ServerFailure(message, statusCode: statusCode);
        }
        return ServerFailure(
          detail ?? 'An error occurred.',
          statusCode: statusCode,
        );
    }
  }
}

extension DioFailure on DioException {
  Failure get failure =>
      error is Failure ? error as Failure : const UnknownFailure();
}
