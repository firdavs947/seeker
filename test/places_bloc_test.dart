import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seeker/src/features/home/data/places_repository.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/home/presentation/bloc/places_bloc.dart';
import 'package:seeker/src/features/home/presentation/bloc/places_event.dart';
import 'package:seeker/src/features/home/presentation/bloc/places_state.dart';

class _MockPlacesRepository extends Mock implements PlacesRepository {}

const _place = Place(
  id: 'p1',
  name: 'Registan',
  category: 'Architecture',
  shortHistory: 'Historic square',
  workTime: '24/7',
  locationLink: 'https://maps.example/registan',
);

void main() {
  late _MockPlacesRepository repository;

  setUp(() => repository = _MockPlacesRepository());

  group('PlacesBloc', () {
    test('начальное состояние — PlacesInitial', () {
      expect(PlacesBloc(repository).state, const PlacesInitial());
    });

    test('успешная загрузка: [PlacesLoading, PlacesLoaded]', () async {
      when(() => repository.fetch()).thenAnswer((_) async => const [_place]);
      final bloc = PlacesBloc(repository);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Object>[
          const PlacesLoading(),
          const PlacesLoaded([_place]),
        ]),
      );

      bloc.add(const PlacesRequested());
      await expectation;
      await bloc.close();
    });

    test('PlaceException превращается в PlacesFailure с текстом', () async {
      when(() => repository.fetch())
          .thenThrow(const PlaceException('No access to places.'));
      final bloc = PlacesBloc(repository);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Object>[
          const PlacesLoading(),
          const PlacesFailure('No access to places.'),
        ]),
      );

      bloc.add(const PlacesRequested());
      await expectation;
      await bloc.close();
    });

    test('неожиданная ошибка превращается в общий PlacesFailure', () async {
      when(() => repository.fetch()).thenThrow(Exception('boom'));
      final bloc = PlacesBloc(repository);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder(<Object>[
          const PlacesLoading(),
          const PlacesFailure('Something went wrong'),
        ]),
      );

      bloc.add(const PlacesRequested());
      await expectation;
      await bloc.close();
    });

    test(
      'droppable: повторные запросы во время загрузки дают один fetch',
      () async {
        final completer = Completer<List<Place>>();
        when(() => repository.fetch()).thenAnswer((_) => completer.future);
        final bloc = PlacesBloc(repository);

        // Первый запрос остаётся «в полёте», пока не завершим completer.
        bloc.add(const PlacesRequested());
        await pumpEventQueue();
        expect(bloc.state, const PlacesLoading());

        // Дубликаты приходят, пока обработчик занят, — они отбрасываются.
        bloc.add(const PlacesRequested());
        bloc.add(const PlacesRequested());
        await pumpEventQueue();

        verify(() => repository.fetch()).called(1);

        completer.complete(const [_place]);
        await bloc.stream.firstWhere((s) => s is PlacesLoaded);
        expect(bloc.state, const PlacesLoaded([_place]));
        await bloc.close();
      },
    );

    test(
      'нагрузка: 1000 быстрых событий без ошибок и рассогласования',
      () async {
        when(() => repository.fetch()).thenAnswer((_) async => const [_place]);
        final bloc = PlacesBloc(repository);

        final errors = <Object>[];
        final states = <PlacesState>[];
        final sub = bloc.stream.listen(states.add, onError: errors.add);

        for (var i = 0; i < 1000; i++) {
          bloc.add(const PlacesRequested());
        }

        // Полностью разгружаем очередь событий.
        await pumpEventQueue(times: 5000);

        expect(errors, isEmpty);
        expect(states, isNotEmpty);
        expect(bloc.state, const PlacesLoaded([_place]));

        await sub.cancel();
        await bloc.close();
      },
    );
  });
}
