import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flow_desk/core/constants/app_constants.dart';
import 'package:flow_desk/data/datasources/auth_remote_datasource.dart';
import 'package:flow_desk/domain/entities/user_entity.dart';
import 'package:flow_desk/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
/// Stores JWT token securely in Keychain (iOS) / Keystore (Android)
/// via flutter_secure_storage — NOT SharedPreferences or memory.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl(this._dataSource, this._secureStorage);

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final token = await _dataSource.login(email: email, password: password);
    // Store token securely — accessible only by this app
    await _secureStorage.write(key: AppConstants.accessTokenKey, value: token);
    return token;
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
    // Delete token from secure storage — session cleared
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }
}
