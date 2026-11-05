import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:seeker/src/features/auth/data/auth_service.dart';
import 'package:seeker/src/features/auth/presentation/bloc/auth_event.dart';
import 'package:seeker/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:seeker/src/features/auth/repository/auth_repository.dart';
import 'package:seeker/src/features/auth/repository/sign_inrepository.dart';

/// Логика экрана входа/регистрации.
///
/// Отправка формы обрабатывается стратегией [droppable]: повторное нажатие
/// кнопки во время запроса игнорируется — двойной сабмит невозможен.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._service) : super(const AuthState()) {
    on<AuthModeChanged>(_onModeChanged);
    on<AuthSubmitted>(_onSubmitted, transformer: droppable());
  }

  final AuthService _service;

  void _onModeChanged(AuthModeChanged event, Emitter<AuthState> emit) {
    // Во время запроса режим не меняем (и UI-контроллер анимации не трогаем).
    if (state.isLoading || event.isSignUp == state.isSignUp) return;
    emit(state.copyWith(isSignUp: event.isSignUp));
  }

  Future<void> _onSubmitted(
    AuthSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      if (state.isSignUp) {
        await _service.register(
          email: event.email,
          username: event.username,
          password: event.password,
        );
      } else {
        await _service.login(email: event.email, password: event.password);
      }
      emit(state.copyWith(status: AuthStatus.success));
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
    } on SigninExseption catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
    } catch (e, st) {
      debugPrint('auth bloc error: $e\n$st');
      emit(state.copyWith(status: AuthStatus.failure, clearError: true));
    }
  }
}
