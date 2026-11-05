import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:seeker/src/core/bloc/app_bloc_observer.dart';
import 'package:seeker/src/core/network/api_client.dart';
import 'package:seeker/src/core/network/token_storage.dart';
import 'package:seeker/src/core/router/app_router.dart';

import 'package:seeker/src/features/auth/data/auth_service.dart';
import 'package:seeker/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seeker/src/features/home/data/places_repository.dart';
import 'package:seeker/src/features/home/presentation/bloc/places_bloc.dart';
import 'package:seeker/src/features/home/presentation/bloc/places_state.dart';
import 'package:seeker/src/features/profile/data/profile_service.dart';
import 'package:seeker/src/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:seeker/src/features/saved/data/saved_store.dart';
import 'package:seeker/src/features/saved/presentation/bloc/saved_bloc.dart';
import 'package:seeker/src/features/saved/repository/saved_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Логирование всех Bloc (события / переходы / ошибки) — только в debug.
  Bloc.observer = const AppBlocObserver();

  await Hive.initFlutter();
  await SavedStorage.init();
  final logged = await TokenStorage.hasSession();

  // Блоки создаём заранее, чтобы роутер мог разрешать deep links
  // (например, /place/:id) по уже загруженным данным.
  final placesBloc = PlacesBloc(const StrapiPlacesRepository());

  final router = AppRouter.create(
    startLogged: logged,
    resolvePlace: (id) {
      final state = placesBloc.state;
      if (state is PlacesLoaded) {
        for (final place in state.places) {
          if (place.id == id) return place;
        }
      }
      return null;
    },
  );

  // Если refresh-токен протух, возвращаем пользователя на экран входа.
  ApiClient.onSessionExpired = () => router.goNamed(AppRouteNames.auth);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru'), Locale('uz')],
      path: 'assets/translator',
      fallbackLocale: const Locale('en'),
      child: MainApp(router: router, placesBloc: placesBloc),
    ),
  );
}

class MainApp extends StatelessWidget {
  final GoRouter router;
  final PlacesBloc placesBloc;

  const MainApp({super.key, required this.router, required this.placesBloc});

  @override
  Widget build(BuildContext context) {
    // Все блоки живут выше MaterialApp.router, поэтому доступны на всех
    // маршрутах (AuthScreen, ProfileScreen, деталях места и т.д.).
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: placesBloc),
        BlocProvider(create: (_) => AuthBloc(const StrapiAuthService())),
        BlocProvider(create: (_) => SavedBloc(const HiveSavedStore())),
        BlocProvider(create: (_) => ProfileBloc(const StrapiProfileService())),
      ],
      child: MaterialApp.router(
        title: 'Seeker',
        debugShowCheckedModeBanner: false,

        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
        routerConfig: router,
      ),
    );
  }
}
