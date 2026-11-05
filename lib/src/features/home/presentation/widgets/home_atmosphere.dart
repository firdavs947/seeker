import 'package:flutter/material.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';

/// Фоновые световые пятна, смещающиеся при прокрутке.
class HomeAtmosphere extends StatelessWidget {
  final ScrollController scroll;

  const HomeAtmosphere({super.key, required this.scroll});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scroll,
      builder: (_, _) {
        final off = scroll.hasClients ? scroll.offset.clamp(0.0, 700.0) : 0.0;
        return Stack(
          children: [
            Positioned(
              right: -130,
              top: -110 - off * 0.25,
              child: _glow(AppColors.coral, 360),
            ),
            Positioned(
              left: -150,
              top: 190 - off * 0.45,
              child: _glow(AppColors.secondaryLight, 340),
            ),
          ],
        );
      },
    );
  }

  Widget _glow(Color c, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [c.withAlpha(64), c.withAlpha(0)]),
        ),
      ),
    );
  }
}
