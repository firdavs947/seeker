import 'package:equatable/equatable.dart';
import 'package:seeker/src/features/home/model/place.dart';

/// Состояния блока списка мест. `sealed` даёт исчерпывающий `switch`
/// и типовую безопасность на стороне UI.
sealed class PlacesState extends Equatable {
  const PlacesState();

  @override
  List<Object?> get props => const [];
}

/// Начальное состояние — данные ещё не запрашивались.
final class PlacesInitial extends PlacesState {
  const PlacesInitial();
}

/// Идёт загрузка.
final class PlacesLoading extends PlacesState {
  const PlacesLoading();
}

/// Данные успешно загружены.
final class PlacesLoaded extends PlacesState {
  final List<Place> places;

  const PlacesLoaded(this.places);

  @override
  List<Object?> get props => [places];
}

/// Загрузка завершилась ошибкой (сообщение готово к показу).
final class PlacesFailure extends PlacesState {
  final String message;

  const PlacesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
