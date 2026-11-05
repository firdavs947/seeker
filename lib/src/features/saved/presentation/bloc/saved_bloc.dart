import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:seeker/src/features/saved/data/saved_store.dart';
import 'package:seeker/src/features/saved/presentation/bloc/saved_event.dart';
import 'package:seeker/src/features/saved/presentation/bloc/saved_state.dart';

/// Блок сохранённых мест (Hive CE).
///
/// Все события обрабатываются стратегией [sequential] — операции над
/// хранилищем выполняются строго в порядке поступления, поэтому быстрые
/// серии «сохранить/убрать» не могут привести к рассогласованию состояния.
class SavedBloc extends Bloc<SavedEvent, SavedState> {
  SavedBloc(this._store) : super(_snapshot(_store)) {
    on<SavedToggleRequested>(_onToggle, transformer: sequential());
    on<SavedRemoveRequested>(_onRemove, transformer: sequential());
    on<SavedRestoreRequested>(_onRestore, transformer: sequential());
    on<SavedClearRequested>(_onClear, transformer: sequential());
  }

  final SavedStore _store;

  static SavedState _snapshot(SavedStore store) {
    final places = store.getAll();
    return SavedState(places: places, savedIds: {for (final p in places) p.id});
  }

  Future<void> _onToggle(
    SavedToggleRequested event,
    Emitter<SavedState> emit,
  ) async {
    await _store.toggle(event.place);
    emit(_snapshot(_store));
  }

  Future<void> _onRemove(
    SavedRemoveRequested event,
    Emitter<SavedState> emit,
  ) async {
    await _store.remove(event.id);
    emit(_snapshot(_store));
  }

  Future<void> _onRestore(
    SavedRestoreRequested event,
    Emitter<SavedState> emit,
  ) async {
    await _store.add(event.place);
    emit(_snapshot(_store));
  }

  Future<void> _onClear(
    SavedClearRequested event,
    Emitter<SavedState> emit,
  ) async {
    await _store.clear();
    emit(_snapshot(_store));
  }
}
