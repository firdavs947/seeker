import 'package:flutter_test/flutter_test.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/saved/data/saved_store.dart';
import 'package:seeker/src/features/saved/presentation/bloc/saved_bloc.dart';
import 'package:seeker/src/features/saved/presentation/bloc/saved_event.dart';

/// Настоящее in-memory хранилище (вместо мока): позволяет проверять реальную
/// согласованность состояния после последовательных операций.
class _FakeSavedStore implements SavedStore {
  _FakeSavedStore([List<Place>? initial]) {
    if (initial != null) _places.addAll(initial);
  }

  final List<Place> _places = [];

  @override
  List<Place> getAll() => List<Place>.of(_places);

  @override
  bool isSaved(String id) => _places.any((p) => p.id == id);

  @override
  Future<void> add(Place place) async {
    if (!isSaved(place.id)) _places.insert(0, place);
  }

  @override
  Future<void> remove(String id) async {
    _places.removeWhere((p) => p.id == id);
  }

  @override
  Future<bool> toggle(Place place) async {
    if (isSaved(place.id)) {
      await remove(place.id);
      return false;
    }
    await add(place);
    return true;
  }

  @override
  Future<void> clear() async {
    _places.clear();
  }
}

Place _placeN(int i) => Place(
  id: 'p$i',
  name: 'Place $i',
  category: 'Category',
  shortHistory: 'History $i',
  workTime: '9-18',
  locationLink: 'https://maps.example/$i',
);

void main() {
  final place = _placeN(1);

  group('SavedBloc', () {
    test('начальное состояние строится из хранилища', () {
      final store = _FakeSavedStore([place]);
      final bloc = SavedBloc(store);

      expect(bloc.state.savedIds, {place.id});
      expect(bloc.state.isSaved(place.id), isTrue);
    });

    test('toggle добавляет место', () async {
      final store = _FakeSavedStore();
      final bloc = SavedBloc(store);

      final done = bloc.stream.firstWhere((s) => s.isSaved(place.id));
      bloc.add(SavedToggleRequested(place));
      await done;

      expect(bloc.state.places.map((p) => p.id), [place.id]);
      expect(store.isSaved(place.id), isTrue);
      await bloc.close();
    });

    test('toggle повторно убирает место', () async {
      final store = _FakeSavedStore([place]);
      final bloc = SavedBloc(store);

      final done = bloc.stream.firstWhere((s) => !s.isSaved(place.id));
      bloc.add(SavedToggleRequested(place));
      await done;

      expect(bloc.state.savedIds, isEmpty);
      await bloc.close();
    });

    test('remove удаляет по id', () async {
      final store = _FakeSavedStore([place]);
      final bloc = SavedBloc(store);

      final done = bloc.stream.firstWhere((s) => !s.isSaved(place.id));
      bloc.add(SavedRemoveRequested(place.id));
      await done;

      expect(bloc.state.places, isEmpty);
      await bloc.close();
    });

    test('restore возвращает место', () async {
      final store = _FakeSavedStore();
      final bloc = SavedBloc(store);

      final done = bloc.stream.firstWhere((s) => s.isSaved(place.id));
      bloc.add(SavedRestoreRequested(place));
      await done;

      expect(bloc.state.savedIds, {place.id});
      await bloc.close();
    });

    test('clear очищает список', () async {
      final store = _FakeSavedStore([place, _placeN(2)]);
      final bloc = SavedBloc(store);

      final done = bloc.stream.firstWhere((s) => s.places.isEmpty);
      bloc.add(const SavedClearRequested());
      await done;

      expect(bloc.state.savedIds, isEmpty);
      await bloc.close();
    });

    test(
      'sequential: быстрая серия toggle/remove сохраняет порядок и итог',
      () async {
        final store = _FakeSavedStore();
        final bloc = SavedBloc(store);

        final done = bloc.stream.firstWhere((s) => s.places.length == 2);
        bloc.add(SavedToggleRequested(_placeN(1)));
        bloc.add(SavedToggleRequested(_placeN(2)));
        bloc.add(SavedToggleRequested(_placeN(3)));
        bloc.add(SavedRemoveRequested('p3'));
        await done;

        expect(bloc.state.savedIds, {'p1', 'p2'});
        expect(bloc.state.places.length, 2);
        await bloc.close();
      },
    );

    test('нагрузка: 300 последовательных операций без ошибок', () async {
      final store = _FakeSavedStore();
      final bloc = SavedBloc(store);

      final errors = <Object>[];
      final sub = bloc.stream.listen((_) {}, onError: errors.add);

      final done = bloc.stream.firstWhere((s) => s.places.length == 300);
      for (var i = 0; i < 300; i++) {
        bloc.add(SavedToggleRequested(_placeN(i)));
      }
      await done;

      expect(bloc.state.places.length, 300);
      expect(errors, isEmpty);

      await sub.cancel();
      await bloc.close();
    });
  });
}
