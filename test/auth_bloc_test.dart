import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seeker/src/features/auth/data/auth_service.dart';
import 'package:seeker/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seeker/src/features/auth/presentation/bloc/auth_event.dart';
import 'package:seeker/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:seeker/src/features/auth/repository/auth_repository.dart';
import 'package:seeker/src/features/auth/repository/sign_inrepository.dart';

class _MockAuthService extends Mock implements AuthService {}

void main() {
  late _MockAuthService service;

  setUp(() => service = _MockAuthService());

  void stubRegisterSuccess() {
    when(
      () => service.register(
        email: any(named: 'email'),
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
  }

  void stubLoginSuccess() {
    when(
      () => service.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
  }

  group('AuthBloc', () {
    test('начальное состояние — idle и вход', () {
      expect(AuthBloc(service).state, const AuthState());
    });

    test('AuthModeChanged переключает режим', () async {
      final bloc = AuthBloc(service);

      final done = bloc.stream.firstWhere((s) => s.isSignUp);
      bloc.add(const AuthModeChanged(true));
      await done;

      expect(bloc.state.isSignUp, isTrue);
      await bloc.close();
    });

    test('повторный AuthModeChanged с тем же значением не эмитит', () async {
      final bloc = AuthBloc(service);
      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthModeChanged(false));
      await Future<void>.delayed(Duration.zero);

      expect(states, isEmpty);
      await sub.cancel();
      await bloc.close();
    });

    test('регистрация успешна: [loading, success] (isSignUp = true)', () async {
      stubRegisterSuccess();
      final bloc = AuthBloc(service);

      final mode = bloc.stream.firstWhere((s) => s.isSignUp);
      bloc.add(const AuthModeChanged(true));
      await mode;

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Object>[
          const AuthState(status: AuthStatus.loading, isSignUp: true),
          const AuthState(status: AuthStatus.success, isSignUp: true),
        ]),
      );

      bloc.add(
        const AuthSubmitted(email: 'a@b.c', username: 'user', password: 'pass'),
      );
      await expectation;
      await bloc.close();
    });

    test('вход успешен: [loading, success] (isSignUp = false)', () async {
      stubLoginSuccess();
      final bloc = AuthBloc(service);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Object>[
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.success),
        ]),
      );

      bloc.add(
        const AuthSubmitted(email: 'a@b.c', username: '', password: 'pass'),
      );
      await expectation;
      await bloc.close();
    });

    test('AuthException при регистрации -> failure с сообщением', () async {
      when(
        () => service.register(
          email: any(named: 'email'),
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException('Email already taken'));
      final bloc = AuthBloc(service);

      final mode = bloc.stream.firstWhere((s) => s.isSignUp);
      bloc.add(const AuthModeChanged(true));
      await mode;

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Object>[
          const AuthState(status: AuthStatus.loading, isSignUp: true),
          const AuthState(
            status: AuthStatus.failure,
            isSignUp: true,
            errorMessage: 'Email already taken',
          ),
        ]),
      );

      bloc.add(
        const AuthSubmitted(email: 'a@b.c', username: 'user', password: 'pass'),
      );
      await expectation;
      await bloc.close();
    });

    test('SigninExseption при входе -> failure с сообщением', () async {
      when(
        () => service.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const SigninExseption('Invalid credentials'));
      final bloc = AuthBloc(service);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Object>[
          const AuthState(status: AuthStatus.loading),
          const AuthState(
            status: AuthStatus.failure,
            errorMessage: 'Invalid credentials',
          ),
        ]),
      );

      bloc.add(
        const AuthSubmitted(email: 'a@b.c', username: '', password: 'pass'),
      );
      await expectation;
      await bloc.close();
    });

    test('неожиданная ошибка -> failure без сообщения', () async {
      when(
        () => service.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('boom'));
      final bloc = AuthBloc(service);

      final done = bloc.stream.firstWhere(
        (s) => s.status == AuthStatus.failure,
      );

      bloc.add(
        const AuthSubmitted(email: 'a@b.c', username: '', password: 'pass'),
      );
      await done;

      expect(bloc.state.errorMessage, isNull);
      await bloc.close();
    });

    test('во время загрузки режим не переключается', () async {
      final completer = Completer<void>();
      when(
        () => service.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => completer.future);
      final bloc = AuthBloc(service);

      final loading = bloc.stream.firstWhere((s) => s.isLoading);
      bloc.add(
        const AuthSubmitted(email: 'a@b.c', username: '', password: 'pass'),
      );
      await loading;

      bloc.add(const AuthModeChanged(true));
      await pumpEventQueue();

      expect(bloc.state.isSignUp, isFalse);

      completer.complete();
      await bloc.close();
    });

    test('droppable: двойной сабмит даёт один вызов сервиса', () async {
      final completer = Completer<void>();
      when(
        () => service.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => completer.future);
      final bloc = AuthBloc(service);

      // Первый сабмит остаётся «в полёте».
      bloc.add(
        const AuthSubmitted(email: 'a@b.c', username: '', password: 'pass'),
      );
      await pumpEventQueue();
      expect(bloc.state.isLoading, isTrue);

      // Повторный сабмит во время запроса игнорируется.
      bloc.add(
        const AuthSubmitted(email: 'a@b.c', username: '', password: 'pass'),
      );
      await pumpEventQueue();

      verify(
        () => service.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).called(1);

      completer.complete();
      await bloc.stream.firstWhere((s) => s.status == AuthStatus.success);
      await bloc.close();
    });

    test('нагрузка: 1000 сабмитов без ошибок, финал — success', () async {
      stubLoginSuccess();
      final bloc = AuthBloc(service);
      final errors = <Object>[];
      final sub = bloc.stream.listen((_) {}, onError: errors.add);

      for (var i = 0; i < 1000; i++) {
        bloc.add(
          const AuthSubmitted(email: 'a@b.c', username: '', password: 'pass'),
        );
      }
      await pumpEventQueue(times: 5000);

      expect(errors, isEmpty);
      expect(bloc.state.status, AuthStatus.success);

      await sub.cancel();
      await bloc.close();
    });
  });
}
