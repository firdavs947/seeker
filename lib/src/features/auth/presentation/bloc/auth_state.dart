import 'package:equatable/equatable.dart';

/// Текущий этап отправки формы.
enum AuthStatus {
  /// Ничего не отправляется.
  idle,

  /// Идёт запрос.
  loading,

  /// Успех (сигнал для навигации).
  success,

  /// Ошибка ([AuthState.errorMessage] содержит текст, если он известен).
  failure,
}

/// Состояние блока аутентификации.
class AuthState extends Equatable {
  final AuthStatus status;
  final bool isSignUp;

  /// Сообщение об ошибке от сервера/репозитория.
  /// `null` при неожиданной ошибке — UI подставит общий текст.
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.idle,
    this.isSignUp = false,
    this.errorMessage,
  });

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    bool? isSignUp,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isSignUp: isSignUp ?? this.isSignUp,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, isSignUp, errorMessage];
}
