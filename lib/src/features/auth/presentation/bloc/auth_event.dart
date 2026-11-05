import 'package:equatable/equatable.dart';

/// События блока аутентификации.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

/// Переключение режима «Вход / Регистрация».
final class AuthModeChanged extends AuthEvent {
  final bool isSignUp;

  const AuthModeChanged(this.isSignUp);

  @override
  List<Object?> get props => [isSignUp];
}

/// Отправка формы. [username] используется только при регистрации.
final class AuthSubmitted extends AuthEvent {
  final String email;
  final String username;
  final String password;

  const AuthSubmitted({
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [email, username, password];
}
