import 'package:equatable/equatable.dart';

/// События блока списка мест.
sealed class PlacesEvent extends Equatable {
  const PlacesEvent();

  @override
  List<Object?> get props => const [];
}

/// Запросить (или перезапросить) список мест.
final class PlacesRequested extends PlacesEvent {
  const PlacesRequested();
}
