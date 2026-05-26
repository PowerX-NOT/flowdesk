import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flow_desk/core/constants/app_constants.dart';
import 'package:flow_desk/data/datasources/auth_remote_datasource.dart';
import 'package:flow_desk/domain/entities/user_entity.dart';
import 'package:flow_desk/domain/repositories/auth_repository.dart';

/// Stores JWT tokens in Keychain (iOS) / Keystore (Android) via flutter_secure_storage.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl(this._dataSource, this._secureStorage);

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final tokens = await _dataSource.login(email: email, password: password);
    await _persistTokens(tokens);
    return tokens.accessToken;
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _dataSource.register(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  @override
  Future<UserEntity> getCurrentUser() => _dataSource.getCurrentUser();

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Attempt silent refresh when access token expired but refresh token exists.
  @override
  Future<bool> refreshSessionIfNeeded() async {
    final refresh = await _secureStorage.read(key: AppConstants.refreshTokenKey);
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final tokens = await _dataSource.refreshSession(refresh);
      await _persistTokens(tokens);
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<void> _persistTokens(AuthTokens tokens) async {
    await _secureStorage.write(
      key: AppConstants.accessTokenKey,
      value: tokens.accessToken,
    );
    final refresh = tokens.refreshToken;
    if (refresh != null && refresh.isNotEmpty) {
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: refresh,
      );
    }
  }
}
