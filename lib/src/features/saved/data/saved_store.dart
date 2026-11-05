import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/saved/repository/saved_storage.dart';

/// Контракт хранилища сохранённых мест.
///
/// Чтение синхронное (данные уже в памяти Hive), запись асинхронная.
abstract interface class SavedStore {
  List<Place> getAll();

  bool isSaved(String id);

  Future<void> add(Place place);

  Future<void> remove(String id);

  Future<bool> toggle(Place place);

  Future<void> clear();
}

/// Реализация поверх Hive CE ([SavedStorage]).
class HiveSavedStore implements SavedStore {
  const HiveSavedStore();

  @override
  List<Place> getAll() => SavedStorage.getAll();

  @override
  bool isSaved(String id) => SavedStorage.isSaved(id);

  @override
  Future<void> add(Place place) => SavedStorage.add(place);

  @override
  Future<void> remove(String id) => SavedStorage.remove(id);

  @override
  Future<bool> toggle(Place place) => SavedStorage.toggle(place);

  @override
  Future<void> clear() => SavedStorage.clear();
}
