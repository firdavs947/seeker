import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/gen/assets.gen.dart';
import 'package:seeker/src/core/widgets/interactive_element.dart';

class _AuthItem {
  final int mode; // 0 — Sign In, 1 — Sign Up
  final AssetGenImage image;
  final IconData icon;
  final double size; // доля от ширины экрана
  final double x; // доля от ширины
  final double y; // доля от высоты шапки
  final double depth;
  final double phase;

  _AuthItem(
    this.mode,
    this.image,
    this.icon,
    this.size,
    this.x,
    this.y, {
    this.depth = 1.0,
    this.phase = 0,
  });
}

final _authItems = <_AuthItem>[
  // Sign In
  _AuthItem(
    0,
    Assets.images.copmass,
    Icons.explore_rounded,
    0.26,
    0.66,
    0.02,
    depth: 1.4,
    phase: 0.8,
  ),
  _AuthItem(
    0,
    Assets.images.camera,
    Icons.photo_camera_rounded,
    0.40,
    0.50,
    0.42,
    depth: 1.1,
    phase: 0.3,
  ),
  _AuthItem(
    0,
    Assets.images.plane,
    Icons.flight_rounded,
    0.32,
    0.06,
    0.58,
    depth: 1.3,
    phase: 0.6,
  ),
  // Sign Up
  _AuthItem(
    1,
    Assets.images.pasport,
    Icons.book_rounded,
    0.28,
    0.62,
    0.02,
    depth: 1.3,
    phase: 0.2,
  ),
  _AuthItem(
    1,
    Assets.images.b,
    Icons.luggage_rounded,
    0.40,
    0.50,
    0.42,
    depth: 1.1,
    phase: 0.7,
  ),
  _AuthItem(
    1,
    Assets.images.ticket,
    Icons.confirmation_number_rounded,
    0.30,
    0.06,
    0.58,
    depth: 1.4,
    phase: 0.4,
  ),
];

/// Летающие декоративные объекты над карточкой: их можно перетаскивать.
class AuthFlyingItems extends StatelessWidget {
  final Animation<double> animation;
  final double width;
  final double headerHeight;

  const AuthFlyingItems({
    super.key,
    required this.animation,
    required this.width,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) => Stack(
        children: [
          for (int i = 0; i < _authItems.length; i++)
            _buildItem(context, i, _authItems[i], animation.value),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, _AuthItem it, double m) {
    final d = it.mode - m; // 0 — активен, ±1 — за кадром
    final t = (1 - d.abs()).clamp(0.0, 1.0);

    final opacity = Curves.easeOut.transform(t);
    final scale = 0.5 + 0.5 * Curves.easeOutBack.transform(t);
    final px = it.size * width;
    final dpr = MediaQuery.of(context).devicePixelRatio;

    final img = it.image.image(
      width: px,
      height: px,
      fit: BoxFit.contain,
      cacheWidth: (px * dpr).round(),
      errorBuilder: (_, _, _) => Container(
        width: px,
        height: px,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(40),
          borderRadius: BorderRadius.circular(px * 0.28),
        ),
        child: Icon(it.icon, color: Colors.white, size: px * 0.5),
      ),
    );

    return Positioned(
      key: ValueKey('auth_item_$index'),
      left: it.x * width + d * width * it.depth,
      top: it.y * headerHeight,
      child: IgnorePointer(
        ignoring: t < 0.6,
        child: Opacity(
          opacity: opacity,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(d * 1.1)
              ..rotateX(d * 0.25),
            child: Transform.scale(
              scale: scale,
              child: InteractiveElement(
                floatPhase: it.phase,
                showShadow: false,
                child: img
                    .animate()
                    .fadeIn(delay: (150 * index).ms, duration: 500.ms)
                    .scale(
                      begin: const Offset(0.4, 0.4),
                      end: const Offset(1, 1),
                      delay: (150 * index).ms,
                      duration: 900.ms,
                      curve: Curves.elasticOut,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
