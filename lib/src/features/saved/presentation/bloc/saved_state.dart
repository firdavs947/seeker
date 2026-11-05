import 'package:equatable/equatable.dart';
import 'package:seeker/src/features/home/model/place.dart';

/// Состояние списка сохранённых мест — единый источник правды для UI.
class SavedState extends Equatable {
  /// Сохранённые места: сначала самые новые.
  final List<Place> places;

  /// id сохранённых мест — для быстрой проверки в кнопке-сердечке.
  final Set<String> savedIds;

  const SavedState({
    this.places = const <Place>[],
    this.savedIds = const <String>{},
  });

  bool isSaved(String id) => savedIds.contains(id);

  @override
  List<Object?> get props => [places, savedIds];
}
