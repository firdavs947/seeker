import 'package:equatable/equatable.dart';

/// События блока профиля.
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => const [];
}

/// Запросить (или перезапросить) профиль.
final class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}
