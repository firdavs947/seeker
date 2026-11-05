import 'package:flutter/material.dart';
import 'package:seeker/gen/assets.gen.dart';

/// Парящий объект онбординга: страница, картинка, позиция (доли ширины/высоты
/// экрана) и параметры параллакса.
class OnboardingItem {
  final int page;
  final AssetGenImage image;
  final IconData icon; // заглушка при ошибке загрузки
  final double size; // доля от ширины экрана
  final double x, y; // доли от ширины / высоты экрана
  final double depth; // сила параллакса
  final double phase;

  const OnboardingItem(
    this.page,
    this.image,
    this.icon,
    this.size,
    this.x,
    this.y, {
    this.depth = 1.0,
    this.phase = 0,
  });
}

// Геттеры flutter_gen не const, поэтому список final.
final kOnboardingItems = <OnboardingItem>[
  // Page 0
  OnboardingItem(
    0,
    Assets.images.map,
    Icons.map_rounded,
    0.40,
    0.06,
    0.09,
    depth: 0.9,
    phase: 0.1,
  ),
  OnboardingItem(
    0,
    Assets.images.bag,
    Icons.backpack_rounded,
    0.46,
    0.46,
    0.20,
    depth: 1.25,
    phase: 0.5,
  ),
  OnboardingItem(
    0,
    Assets.images.bottle,
    Icons.water_drop_rounded,
    0.30,
    0.10,
    0.38,
    depth: 1.5,
    phase: 0.9,
  ),
  // Page 1
  OnboardingItem(
    1,
    Assets.images.pasport,
    Icons.book_rounded,
    0.34,
    0.08,
    0.09,
    depth: 1.1,
    phase: 0.3,
  ),
  OnboardingItem(
    1,
    Assets.images.plane,
    Icons.flight_rounded,
    0.50,
    0.42,
    0.22,
    depth: 1.4,
    phase: 0.7,
  ),
  OnboardingItem(
    1,
    Assets.images.b,
    Icons.luggage_rounded,
    0.38,
    0.08,
    0.40,
    depth: 0.9,
    phase: 0.2,
  ),
  // Page 2
  OnboardingItem(
    2,
    Assets.images.camera,
    Icons.photo_camera_rounded,
    0.44,
    0.07,
    0.10,
    depth: 1.0,
    phase: 0.4,
  ),
  OnboardingItem(
    2,
    Assets.images.copmass,
    Icons.explore_rounded,
    0.34,
    0.58,
    0.12,
    depth: 1.4,
    phase: 0.8,
  ),
  OnboardingItem(
    2,
    Assets.images.ticket,
    Icons.confirmation_number_rounded,
    0.38,
    0.46,
    0.36,
    depth: 1.2,
    phase: 0.1,
  ),
];
