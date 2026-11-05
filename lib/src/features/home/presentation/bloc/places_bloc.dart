import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:seeker/src/features/home/data/places_repository.dart';
import 'package:seeker/src/features/home/presentation/bloc/places_event.dart';
import 'package:seeker/src/features/home/presentation/bloc/places_state.dart';

/// Загрузка списка мест для главного экрана.
///
/// События обрабатываются стратегией [droppable]: повторное нажатие «Retry»
/// во время активной загрузки игнорируется, поэтому дублирующих сетевых
/// запросов и «гонок» состояний не возникает.
class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  PlacesBloc(this._repository) : super(const PlacesInitial()) {
    on<PlacesRequested>(_onRequested, transformer: droppable());
  }

  final PlacesRepository _repository;

  Future<void> _onRequested(
    PlacesRequested event,
    Emitter<PlacesState> emit,
  ) async {
    emit(const PlacesLoading());
    try {
      final places = await _repository.fetch();
      emit(PlacesLoaded(places));
    } on PlaceException catch (e) {
      emit(PlacesFailure(e.message));
    } catch (e, st) {
      debugPrint('places bloc error: $e\n$st');
      emit(const PlacesFailure('Something went wrong'));
    }
  }
}
