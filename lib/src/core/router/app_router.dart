import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/core/network/token_storage.dart';
import 'package:seeker/src/features/auth/presentation/screens/auth_screen.dart';
import 'package:seeker/src/features/detail/presentation/screens/place_detail_screen.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/home/presentation/screens/home_loader.dart';
import 'package:seeker/src/features/home/presentation/screens/main_screens.dart';
import 'package:seeker/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:seeker/src/features/profile/presentation/screens/proifle_screen.dart';
import 'package:seeker/src/features/saved/presentation/screens/saved_screen.dart';

/// Пути всех маршрутов приложения — единый источник правды.
abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const auth = '/auth';

  /// Оболочка нижней навигации. Вкладки — вложенные маршруты.
  static const home = '/home';
  static const trips = '/home/trips';
  static const saved = '/home/saved';
  static const profile = '/home/profile';

  /// Детали места: `id` — обязательный параметр пути.
  static const placePattern = '/place/:id';

  static String place(String id) => '/place/$id';
}

/// Имена маршрутов для типобезопасной навигации (goNamed / pushNamed).
abstract final class AppRouteNames {
  static const onboarding = 'onboarding';
  static const auth = 'auth';
  static const home = 'home';
  static const trips = 'trips';
  static const saved = 'saved';
  static const profile = 'profile';
  static const place = 'place';
}

/// Типизированные аргументы маршрута деталей места.
///
/// [place] — обязательный (объект, который нельзя сериализовать в URL),
/// [heroTag] — необязательный (например, для анимации Hero при переходе).
class PlaceDetailsArgs {
  final Place place;
  final String? heroTag;

  const PlaceDetailsArgs({required this.place, this.heroTag});
}

/// Проверка активной сессии. Инжектится, чтобы роутер был тестируемым.
typedef SessionCheck = Future<bool> Function();

/// Централизованная конфигурация навигации на go_router.
class AppRouter {
  AppRouter._();

  /// Корневой навигатор: используется для маршрутов поверх оболочки вкладок
  /// (например, детали места) и для внешних переходов по сессии.
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Создаёт [GoRouter] со всеми маршрутами, редиректами и обработкой 404.
  static GoRouter create({
    required bool startLogged,
    SessionCheck isLoggedIn = TokenStorage.hasSession,
    Place? Function(String id)? resolvePlace,
  }) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: startLogged ? AppRoutes.home : AppRoutes.onboarding,
      // Редирект с проверкой сессии (защита приватных маршрутов).
      redirect: (context, state) async => redirectTarget(
        location: state.matchedLocation,
        loggedIn: await isLoggedIn(),
      ),
      routes: _routes(resolvePlace: resolvePlace),
      errorBuilder: (context, state) =>
          _NotFoundScreen(location: state.uri.toString()),
    );
  }

  static List<RouteBase> _routes({Place? Function(String id)? resolvePlace}) {
    return [
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRouteNames.onboarding,
        pageBuilder: (context, state) =>
            _fadePage(state, const OnboardingScreen(), 600),
      ),
      GoRoute(
        path: AppRoutes.auth,
        name: AppRouteNames.auth,
        pageBuilder: (context, state) =>
            _fadePage(state, const AuthScreen(), 600),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRouteNames.home,
                builder: (context, state) => const HomeLoader(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.trips,
                name: AppRouteNames.trips,
                builder: (context, state) => const TripsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.saved,
                name: AppRouteNames.saved,
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.placePattern,
        name: AppRouteNames.place,
        // Открывается поверх оболочки вкладок, на корневом навигаторе.
        parentNavigatorKey: rootNavigatorKey,
        redirect: (context, state) {
          final hasArgs = state.extra is PlaceDetailsArgs;
          final id = state.pathParameters['id'];
          // Deep link без extra: пробуем найти место среди загруженных.
          if (!hasArgs && (id == null || resolvePlace?.call(id) == null)) {
            return AppRoutes.home;
          }
          return null;
        },
        pageBuilder: (context, state) {
          final args = state.extra as PlaceDetailsArgs?;
          // redirect выше гарантирует, что место будет найдено.
          final place =
              args?.place ?? resolvePlace!(state.pathParameters['id']!)!;
          final heroTag = args?.heroTag ?? state.uri.queryParameters['hero'];
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: PlaceDetailsScreen(place: place, heroTag: heroTag),
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 450),
            transitionsBuilder: (context, animation, secondary, child) =>
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                  child: child,
                ),
          );
        },
      ),
    ];
  }

  /// Чистая логика редиректов (покрывается юнит-тестами).
  ///
  /// * неавторизованный на защищённом маршруте -> [/AppRoutes.auth];
  /// * авторизованный на публичном маршруте -> [/AppRoutes.home];
  /// * неизвестный маршрут не трогаем — его отрисует `errorBuilder` (404).
  static String? redirectTarget({
    required String location,
    required bool loggedIn,
  }) {
    final isPublic =
        location == AppRoutes.onboarding || location == AppRoutes.auth;
    final isProtected =
        location == AppRoutes.home ||
        location.startsWith('${AppRoutes.home}/') ||
        location.startsWith('/place');

    if (!loggedIn && isProtected) return AppRoutes.auth;
    if (loggedIn && isPublic) return AppRoutes.home;
    return null;
  }

  static Page<void> _fadePage(
    GoRouterState state,
    Widget child,
    int milliseconds,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration(milliseconds: milliseconds),
      reverseTransitionDuration: Duration(milliseconds: milliseconds),
      transitionsBuilder: (context, animation, secondary, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}

/// Страница 404 для несуществующих маршрутов.
class _NotFoundScreen extends StatelessWidget {
  final String location;

  const _NotFoundScreen({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.explore_off_rounded,
                  size: 72,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 20),
                const Text(
                  '404',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This page does not exist',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  location,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => context.goNamed(AppRouteNames.home),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Go home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
