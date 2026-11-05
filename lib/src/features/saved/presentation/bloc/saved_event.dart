import 'package:equatable/equatable.dart';
import 'package:seeker/src/features/home/model/place.dart';

/// События блока сохранённых мест.
sealed class SavedEvent extends Equatable {
  const SavedEvent();

  @override
  List<Object?> get props => const [];
}

/// Сохранить/убрать место (кнопка-сердечко).
final class SavedToggleRequested extends SavedEvent {
  final Place place;

  const SavedToggleRequested(this.place);

  @override
  List<Object?> get props => [place.id];
}

/// Удалить место по id.
final class SavedRemoveRequested extends SavedEvent {
  final String id;

  const SavedRemoveRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Вернуть место обратно (кнопка «Отменить» в снекбаре).
final class SavedRestoreRequested extends SavedEvent {
  final Place place;

  const SavedRestoreRequested(this.place);

  @override
  List<Object?> get props => [place.id];
}

/// Очистить весь список.
final class SavedClearRequested extends SavedEvent {
  const SavedClearRequested();
}
