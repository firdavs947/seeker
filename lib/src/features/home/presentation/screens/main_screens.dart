import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/home/presentation/screens/app_nav_bar.dart';

/// Оболочка нижней навигации. Вкладки — вложенные маршруты go_router
/// ([StatefulShellRoute.indexedStack] сохраняет состояние каждой вкладки).
class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  static const _items = [
    AppNavItem(icon: Icons.home_rounded, label: 'Home'),
    AppNavItem(icon: Icons.card_travel_rounded, label: 'Trips'),
    AppNavItem(icon: Icons.favorite_rounded, label: 'Saved'),
    AppNavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppNavBar(
              items: _items,
              currentIndex: navigationShell.currentIndex,
              // Повторный тап по активной вкладке возвращает её к корню.
              onTap: (i) => navigationShell.goBranch(
                i,
                initialLocation: i == navigationShell.currentIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Trips\ncoming soon',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          height: 1.3,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
