import 'package:dio/dio.dart';
import 'package:flow_desk/core/errors/failures.dart';
import 'package:flow_desk/data/datasources/api_client.dart';
import 'package:flow_desk/data/models/user_model.dart';

class AuthTokens {
  final String accessToken;
  final String? refreshToken;

  const AuthTokens({required this.accessToken, this.refreshToken});
}

/// Remote data source for all auth API calls
class AuthRemoteDataSource {
  final ApiClient _apiClient;
  AuthRemoteDataSource(this._apiClient);

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      final access = data['access_token'] as String?;
      if (access == null || access.isEmpty) {
        throw const ServerFailure('Invalid response from server.');
      }
      return AuthTokens(
        accessToken: access,
        refreshToken: data['refresh_token'] as String?,
      );
    } on DioException catch (e) {
      throw e.failure;
    }
  }

  Future<AuthTokens> refreshSession(String refreshToken) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      final access = data['access_token'] as String?;
      if (access == null || access.isEmpty) {
        throw const UnauthorizedFailure();
      }
      return AuthTokens(
        accessToken: access,
        refreshToken: data['refresh_token'] as String?,
      );
    } on DioException catch (e) {
      throw e.failure;
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.failure;
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get('/users/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.failure;
    }
  }
}
