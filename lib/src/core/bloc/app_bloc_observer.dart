import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Централизованное логирование всех событий, переходов состояний и ошибок.
///
/// Подключается один раз в `main()`: `Bloc.observer = const AppBlocObserver();`
/// Логи выводятся только в debug-сборке, чтобы не влиять на релиз.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      debugPrint(
        '[bloc] ${bloc.runtimeType} event → ${event.runtimeType} $event',
      );
    }
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint('[bloc] ${bloc.runtimeType} change → ${change.nextState}');
    }
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint(
        '[bloc] ${bloc.runtimeType} transition → '
        '${transition.currentState} ⇒ ${transition.nextState}',
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[bloc] ${bloc.runtimeType} error → $error\n$stackTrace');
    }
    super.onError(bloc, error, stackTrace);
  }
}
