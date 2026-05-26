import 'package:flow_desk/domain/entities/user_entity.dart';
import 'package:flow_desk/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<String> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}

class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _repository.register(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}

class LogoutUseCase {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<void> call() => _repository.logout();
}

class GetCurrentUserUseCase {
  final AuthRepository _repository;
  const GetCurrentUserUseCase(this._repository);

  Future<UserEntity> call() => _repository.getCurrentUser();
}

class IsAuthenticatedUseCase {
  final AuthRepository _repository;
  const IsAuthenticatedUseCase(this._repository);

  Future<bool> call() => _repository.isAuthenticated();
}
