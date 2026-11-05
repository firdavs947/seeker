import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:seeker/src/features/profile/data/profile_service.dart';
import 'package:seeker/src/features/profile/presentation/bloc/profile_event.dart';
import 'package:seeker/src/features/profile/presentation/bloc/profile_state.dart';
import 'package:seeker/src/features/profile/repo/profile_repository.dart';

/// Загрузка профиля пользователя.
///
/// События обрабатываются стратегией [droppable]: повторный запрос во время
/// активной загрузки игнорируется, поэтому дублирующих сетевых вызовов нет.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._service) : super(const ProfileState()) {
    on<ProfileRequested>(_onRequested, transformer: droppable());
  }

  final ProfileService _service;

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    try {
      final profile = await _service.fetch();
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } on ProfileException catch (e) {
      debugPrint('profile bloc error: ${e.message}');
      emit(
        state.copyWith(status: ProfileStatus.failure, errorMessage: e.message),
      );
    } catch (e, st) {
      debugPrint('profile bloc error: $e\n$st');
      emit(state.copyWith(status: ProfileStatus.failure, clearError: true));
    }
  }
}
