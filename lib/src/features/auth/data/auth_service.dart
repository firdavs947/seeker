import 'package:seeker/src/features/auth/repository/auth_repository.dart';
import 'package:seeker/src/features/auth/repository/sign_inrepository.dart';

/// Контракт аутентификации. Блок работает через абстракцию, поэтому в тестах
/// сетевые вызовы полностью подменяются.
abstract interface class AuthService {
  Future<void> register({
    required String email,
    required String username,
    required String password,
  });

  Future<void> login({required String email, required String password});
}

/// Реализация поверх Strapi. Делегирует в существующие репозитории,
/// сохраняя прежнее поведение и типы ошибок.
class StrapiAuthService implements AuthService {
  const StrapiAuthService();

  @override
  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) {
    return AuthRepository.register(
      email: email,
      username: username,
      password: password,
    );
  }

  @override
  Future<void> login({required String email, required String password}) {
    return SigninRepository.login(email: email, password: password);
  }
}
