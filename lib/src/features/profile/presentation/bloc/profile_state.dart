import 'package:equatable/equatable.dart';
import 'package:seeker/src/features/profile/repo/profile_repository.dart';

/// Текущий этап загрузки профиля.
enum ProfileStatus { initial, loading, success, failure }

/// Состояние блока профиля.
///
/// Профиль хранится отдельно от [status]: при обновлении (pull-to-refresh)
/// предыдущие данные остаются на экране, пока не придут новые — UI не мигает
/// скелетоном.
class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;

  /// Сообщение об ошибке (если известно).
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  bool get isLoading => status == ProfileStatus.loading;

  bool get hasFailed => status == ProfileStatus.failure;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
