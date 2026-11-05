import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seeker/src/features/profile/data/profile_service.dart';
import 'package:seeker/src/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:seeker/src/features/profile/presentation/bloc/profile_event.dart';
import 'package:seeker/src/features/profile/presentation/bloc/profile_state.dart';
import 'package:seeker/src/features/profile/repo/profile_repository.dart';

class _MockProfileService extends Mock implements ProfileService {}

const _profile = UserProfile(username: 'seeker', email: 'seeker@example.com');

void main() {
  late _MockProfileService service;

  setUp(() => service = _MockProfileService());

  group('ProfileBloc', () {
    test('начальное состояние — initial без профиля', () {
      expect(ProfileBloc(service).state, const ProfileState());
    });

    test('успешная загрузка: [loading, success(profile)]', () async {
      when(() => service.fetch()).thenAnswer((_) async => _profile);
      final bloc = ProfileBloc(service);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Object>[
          const ProfileState(status: ProfileStatus.loading),
          const ProfileState(status: ProfileStatus.success, profile: _profile),
        ]),
      );

      bloc.add(const ProfileRequested());
      await expectation;
      await bloc.close();
    });

    test('ProfileException -> failure с сообщением', () async {
      when(() => service.fetch())
          .thenThrow(const ProfileException('Can not load profile'));
      final bloc = ProfileBloc(service);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Object>[
          const ProfileState(status: ProfileStatus.loading),
          const ProfileState(
            status: ProfileStatus.failure,
            errorMessage: 'Can not load profile',
          ),
        ]),
      );

      bloc.add(const ProfileRequested());
      await expectation;
      await bloc.close();
    });

    test('неожиданная ошибка -> failure без сообщения', () async {
      when(() => service.fetch()).thenThrow(Exception('boom'));
      final bloc = ProfileBloc(service);

      final done = bloc.stream.firstWhere(
        (s) => s.status == ProfileStatus.failure,
      );
      bloc.add(const ProfileRequested());
      await done;

      expect(bloc.state.errorMessage, isNull);
      await bloc.close();
    });

    test('при обновлении сохраняет предыдущий профиль (нет мигания)', () async {
      when(() => service.fetch()).thenAnswer((_) async => _profile);
      final bloc = ProfileBloc(service);

      final first = bloc.stream.firstWhere((s) => s.profile != null);
      bloc.add(const ProfileRequested());
      await first;

      final states = <ProfileState>[];
      final sub = bloc.stream.listen(states.add);
      final second = bloc.stream.firstWhere(
        (s) => s.status == ProfileStatus.success,
      );
      bloc.add(const ProfileRequested());
      await second;

      expect(states.first.status, ProfileStatus.loading);
      expect(states.first.profile, _profile);

      await sub.cancel();
      await bloc.close();
    });

    test(
      'droppable: повторный запрос во время загрузки игнорируется',
      () async {
        final completer = Completer<UserProfile>();
        when(() => service.fetch()).thenAnswer((_) => completer.future);
        final bloc = ProfileBloc(service);

        // Первый запрос остаётся «в полёте», пока не завершим completer.
        bloc.add(const ProfileRequested());
        await pumpEventQueue();
        expect(bloc.state.status, ProfileStatus.loading);

        // Дубликаты приходят, пока обработчик занят, — они отбрасываются.
        bloc.add(const ProfileRequested());
        bloc.add(const ProfileRequested());
        await pumpEventQueue();

        verify(() => service.fetch()).called(1);

        completer.complete(_profile);
        await bloc.stream.firstWhere((s) => s.status == ProfileStatus.success);
        expect(bloc.state.status, ProfileStatus.success);
        await bloc.close();
      },
    );

    test('нагрузка: 500 быстрых запросов без ошибок', () async {
      when(() => service.fetch()).thenAnswer((_) async => _profile);
      final bloc = ProfileBloc(service);

      final errors = <Object>[];
      final sub = bloc.stream.listen((_) {}, onError: errors.add);

      for (var i = 0; i < 500; i++) {
        bloc.add(const ProfileRequested());
      }

      // Полностью разгружаем очередь событий.
      await pumpEventQueue(times: 5000);

      expect(bloc.state.status, ProfileStatus.success);
      expect(errors, isEmpty);

      await sub.cancel();
      await bloc.close();
    });
  });
}
