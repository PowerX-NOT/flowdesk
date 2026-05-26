import 'package:flow_desk/domain/entities/user_entity.dart';

/// Abstract repository interface for authentication operations
abstract class AuthRepository {
  /// Login with email and password — returns JWT token on success
  Future<String> login({required String email, required String password});

  /// Register a new user account
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  });

  /// Get the currently authenticated user's profile
  Future<UserEntity> getCurrentUser();

  /// Logout — clears stored token
  Future<void> logout();

  /// Returns true if a valid token exists in secure storage
  Future<bool> isAuthenticated();
}
