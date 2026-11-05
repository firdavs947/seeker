import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker/src/core/router/app_router.dart';
import 'package:seeker/src/features/auth/data/auth_service.dart';
import 'package:seeker/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seeker/src/features/auth/presentation/screens/auth_screen.dart';
import 'package:seeker/src/features/detail/presentation/screens/place_detail_screen.dart';
import 'package:seeker/src/features/home/data/places_repository.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/home/presentation/bloc/places_bloc.dart';
import 'package:seeker/src/features/home/presentation/screens/main_screens.dart';
import 'package:seeker/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:seeker/src/features/profile/data/profile_service.dart';
import 'package:seeker/src/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:seeker/src/features/profile/repo/profile_repository.dart';
import 'package:seeker/src/features/saved/data/saved_store.dart';
import 'package:seeker/src/features/saved/presentation/bloc/saved_bloc.dart';
import 'package:seeker/src/features/saved/presentation/screens/saved_screen.dart';

// ===========================================================================
//  Фейковые реализации контрактов (без сети, без Hive, без плагинов)
// ===========================================================================

Place _place(String id) => Place(
  id: id,
  name: 'Place $id',
  category: 'Beach',
  shortHistory: 'History $id',
  workTime: '9-18',
  locationLink: 'https://maps.example/$id',
);

class _FakePlacesRepository implements PlacesRepository {
  @override
  Future<List<Place>> fetch() async => const <Place>[];
}

class _FakeAuthService implements AuthService {
  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {}
}

class _FakeProfileService implements ProfileService {
  @override
  Future<UserProfile> fetch() async =>
      const UserProfile(username: 'tester', email: 'tester@example.com');
}

class _FakeSavedStore implements SavedStore {
  final List<Place> _places = [];

  @override
  List<Place> getAll() => List<Place>.of(_places);

  @override
  bool isSaved(String id) => _places.any((p) => p.id == id);

  @override
  Future<void> add(Place place) async {
    if (!isSaved(place.id)) _places.insert(0, place);
  }

  @override
  Future<void> remove(String id) async {
    _places.removeWhere((p) => p.id == id);
  }

  @override
  Future<bool> toggle(Place place) async {
    if (isSaved(place.id)) {
      await remove(place.id);
      return false;
    }
    await add(place);
    return true;
  }

  @override
  Future<void> clear() async => _places.clear();
}

/// Загрузчик переводов без файлового ввода-вывода: возвращает пустой словарь,
/// поэтому `.tr()` отдаёт ключ, а тест не зависит от содержимого JSON-файлов.
class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      const <String, dynamic>{};
}

// ===========================================================================
//  Тестовое окружение
// ===========================================================================

class _Rig {
  _Rig({
    required this.router,
    required this.places,
    required this.auth,
    required this.profile,
    required this.saved,
  });

  final GoRouter router;
  final PlacesBloc places;
  final AuthBloc auth;
  final ProfileBloc profile;
  final SavedBloc saved;
}

_Rig _rig({required bool logged, Place? Function(String id)? resolvePlace}) {
  return _Rig(
    router: AppRouter.create(
      startLogged: logged,
      isLoggedIn: () async => logged,
      resolvePlace: resolvePlace,
    ),
    places: PlacesBloc(_FakePlacesRepository()),
    auth: AuthBloc(_FakeAuthService()),
    profile: ProfileBloc(_FakeProfileService()),
    saved: SavedBloc(_FakeSavedStore()),
  );
}

Future<void> _pump(WidgetTester tester, _Rig rig) async {
  // Логический размер 600x1200. Тестовый шрифт рисует каждый глиф квадратом
  // (advance == fontSize), поэтому заголовок HomeScreen шире, чем на реальном
  // устройстве, и при ширине 360 переполняет Row. Это артефакт тестовой среды,
  // а не дефект UI, поэтому просто даём вьюпорту больше места.
  tester.view.physicalSize = const Size(600, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      saveLocale: false,
      path: 'assets/translator',
      assetLoader: const _InMemoryAssetLoader(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: rig.places),
          BlocProvider.value(value: rig.auth),
          BlocProvider.value(value: rig.profile),
          BlocProvider.value(value: rig.saved),
        ],
        child: Builder(
          builder: (context) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: rig.router,
          ),
        ),
      ),
    ),
  );

  // Завершение асинхронной загрузки переводов + отработка перехода.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}

/// Разбирает дерево, чтобы отменить все таймеры экранов до конца теста.
///
/// Сначала прокручиваем время: одноразовые отложенные таймеры экранов
/// (`Future.delayed`, анимации) должны сработать до разбора дерева, иначе
/// `flutter_test` падает с «A Timer is still pending even after the widget
/// tree was disposed». Периодические таймеры (`HomeScreen._hintTimer`)
/// отменяются в `dispose` при разборе дерева.
Future<void> _disposeTree(WidgetTester tester) async {
  // 1) Пока дерево живо — даём одноразовым отложенным таймерам экранов
  //    (например, анимации подчёркивания) сработать в корректном состоянии.
  await tester.pump(const Duration(seconds: 3));
  // 2) Разбираем дерево: `dispose` отменяет периодические таймеры.
  await tester.pumpWidget(const SizedBox.shrink());
  // 3) Оставшиеся одноразовые таймеры, запланированные до разбора, догорают
  //    здесь (колбэки защищены проверкой `mounted`).
  await tester.pump(const Duration(seconds: 3));
  await tester.pump();
}

void main() {
  // -------------------------------------------------------------------------
  //  1. Чистая логика редиректов
  // -------------------------------------------------------------------------
  group('AppRouter.redirectTarget', () {
    test('неавторизованный: публичные маршруты не редиректят', () {
      expect(
        AppRouter.redirectTarget(
          location: AppRoutes.onboarding,
          loggedIn: false,
        ),
        isNull,
      );
      expect(
        AppRouter.redirectTarget(location: AppRoutes.auth, loggedIn: false),
        isNull,
      );
    });

    test('неавторизованный: защищённые маршруты ведут на /auth', () {
      for (final location in [
        AppRoutes.home,
        AppRoutes.trips,
        AppRoutes.saved,
        AppRoutes.profile,
        AppRoutes.place('abc'),
      ]) {
        expect(
          AppRouter.redirectTarget(location: location, loggedIn: false),
          AppRoutes.auth,
          reason: 'location: $location',
        );
      }
    });

    test('авторизованный: публичные маршруты ведут на /home', () {
      expect(
        AppRouter.redirectTarget(
          location: AppRoutes.onboarding,
          loggedIn: true,
        ),
        AppRoutes.home,
      );
      expect(
        AppRouter.redirectTarget(location: AppRoutes.auth, loggedIn: true),
        AppRoutes.home,
      );
    });

    test('авторизованный: защищённые маршруты не редиректят', () {
      for (final location in [
        AppRoutes.home,
        AppRoutes.saved,
        AppRoutes.profile,
        AppRoutes.place('abc'),
      ]) {
        expect(
          AppRouter.redirectTarget(location: location, loggedIn: true),
          isNull,
          reason: 'location: $location',
        );
      }
    });

    test('неизвестный маршрут не перехватывается редиректом (404)', () {
      expect(
        AppRouter.redirectTarget(location: '/unknown', loggedIn: false),
        isNull,
      );
      expect(
        AppRouter.redirectTarget(location: '/unknown', loggedIn: true),
        isNull,
      );
    });
  });

  group('AppRoutes', () {
    test('шаблон деталей места подставляет id', () {
      expect(AppRoutes.place('p1'), '/place/p1');
    });
  });

  // -------------------------------------------------------------------------
  //  2. Реальная навигация через GoRouter
  // -------------------------------------------------------------------------
  group('Навигация go_router', () {
    testWidgets('неавторизованный стартует с онбординга', (tester) async {
      final rig = _rig(logged: false);
      await _pump(tester, rig);

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(rig.router.state.matchedLocation, AppRoutes.onboarding);

      await _disposeTree(tester);
    });

    testWidgets('авторизованный стартует с оболочки вкладок', (tester) async {
      final rig = _rig(logged: true);
      await _pump(tester, rig);

      expect(find.byType(MainScreen), findsOneWidget);
      expect(rig.router.state.matchedLocation, AppRoutes.home);

      await _disposeTree(tester);
    });

    testWidgets('редирект: неавторизованный /home -> экран входа', (
      tester,
    ) async {
      final rig = _rig(logged: false);
      await _pump(tester, rig);

      rig.router.go(AppRoutes.home);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(rig.router.state.matchedLocation, AppRoutes.auth);
      expect(find.byType(AuthScreen), findsOneWidget);

      await _disposeTree(tester);
    });

    testWidgets('редирект: авторизованный /auth -> домашняя вкладка', (
      tester,
    ) async {
      final rig = _rig(logged: true);
      await _pump(tester, rig);

      rig.router.go(AppRoutes.auth);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(rig.router.state.matchedLocation, AppRoutes.home);
      expect(find.byType(MainScreen), findsOneWidget);

      await _disposeTree(tester);
    });

    testWidgets('переключение между вкладками оболочки', (tester) async {
      final rig = _rig(logged: true);
      await _pump(tester, rig);

      rig.router.go(AppRoutes.saved);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(rig.router.state.matchedLocation, AppRoutes.saved);
      expect(find.byType(SavedScreen), findsOneWidget);

      await _disposeTree(tester);
    });

    testWidgets('404: неизвестный маршрут показывает страницу ошибки', (
      tester,
    ) async {
      final rig = _rig(logged: true);
      await _pump(tester, rig);

      rig.router.go('/this-route-does-not-exist');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('404'), findsOneWidget);
      expect(find.text('Go home'), findsOneWidget);

      await _disposeTree(tester);
    });

    testWidgets('передача параметров: place через extra', (tester) async {
      final rig = _rig(logged: true);
      await _pump(tester, rig);

      final place = _place('p1');
      rig.router.pushNamed(
        AppRouteNames.place,
        pathParameters: {'id': place.id},
        extra: PlaceDetailsArgs(place: place),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final screen = tester.widget<PlaceDetailsScreen>(
        find.byType(PlaceDetailsScreen),
      );
      expect(screen.place.id, 'p1');
      expect(rig.router.state.matchedLocation, AppRoutes.place('p1'));

      await _disposeTree(tester);
    });

    testWidgets('возврат назад: pop закрывает экран деталей', (tester) async {
      final rig = _rig(logged: true);
      await _pump(tester, rig);

      final place = _place('p2');
      rig.router.pushNamed(
        AppRouteNames.place,
        pathParameters: {'id': place.id},
        extra: PlaceDetailsArgs(place: place),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byType(PlaceDetailsScreen), findsOneWidget);

      rig.router.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(PlaceDetailsScreen), findsNothing);
      expect(find.byType(MainScreen), findsOneWidget);

      await _disposeTree(tester);
    });

    testWidgets('deep link /place/:id резолвится через resolvePlace', (
      tester,
    ) async {
      final rig = _rig(
        logged: true,
        resolvePlace: (id) => id == 'p9' ? _place('p9') : null,
      );
      await _pump(tester, rig);

      rig.router.go(AppRoutes.place('p9'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final screen = tester.widget<PlaceDetailsScreen>(
        find.byType(PlaceDetailsScreen),
      );
      expect(screen.place.id, 'p9');

      await _disposeTree(tester);
    });

    testWidgets('deep link без данных перенаправляет на /home', (tester) async {
      final rig = _rig(logged: true, resolvePlace: (_) => null);
      await _pump(tester, rig);

      rig.router.go(AppRoutes.place('missing'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(rig.router.state.matchedLocation, AppRoutes.home);
      expect(find.byType(PlaceDetailsScreen), findsNothing);

      await _disposeTree(tester);
    });
  });
}
