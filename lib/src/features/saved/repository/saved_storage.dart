import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:seeker/src/features/home/model/place.dart';

/// Сохранённые места (кеш на устройстве, Hive CE).
/// Каждое место лежит как JSON-строка под ключом = id места.
class SavedStorage {
  SavedStorage._();

  static const String _boxName = 'saved_places';
  static late Box<String> _box;

  /// Вызвать один раз в main() после Hive.initFlutter()
  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Для ValueListenableBuilder: экран обновляется при любом изменении
  static ValueListenable<Box<String>> get listenable => _box.listenable();

  static bool isSaved(String id) => _box.containsKey(id);

  /// Все сохранённые места: сначала самые новые
  static List<Place> getAll() {
    final items = <MapEntry<int, Place>>[];

    for (final raw in _box.values) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
        final savedAt = (map['savedAt'] as num?)?.toInt() ?? 0;
        items.add(MapEntry(savedAt, Place.fromCache(map)));
      } catch (e) {
        debugPrint('saved: bad entry skipped: $e');
      }
    }

    items.sort((a, b) => b.key.compareTo(a.key));
    return [for (final e in items) e.value];
  }

  static Future<void> add(Place place) {
    final map = place.toJson()
      ..['savedAt'] = DateTime.now().millisecondsSinceEpoch;
    return _box.put(place.id, jsonEncode(map));
  }

  static Future<void> remove(String id) => _box.delete(id);

  /// Возвращает true, если место теперь сохранено
  static Future<bool> toggle(Place place) async {
    if (isSaved(place.id)) {
      await remove(place.id);
      return false;
    }
    await add(place);
    return true;
  }

  static Future<void> clear() => _box.clear();
}
