import 'package:flutter/material.dart';

/// Фон экрана авторизации: градиент и декоративные круги,
/// плавно меняющиеся при переключении режима.
class AuthBackground extends StatelessWidget {
  final Animation<double> animation;
  final double width;
  final double height;

  const AuthBackground({
    super.key,
    required this.animation,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        final m = animation.value;
        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(
                        const Color(0xFF7E57C2),
                        const Color(0xFF42A5F5),
                        m,
                      )!,
                      Color.lerp(
                        const Color(0xFF4527A0),
                        const Color(0xFF1565C0),
                        m,
                      )!,
                    ],
                  ),
                ),
              ),
            ),
            _circle(
              -width * 0.25 - m * width * 0.2,
              height * 0.02,
              width * 0.8,
              26,
            ),
            _circle(
              width * 0.55 - m * width * 0.3,
              height * 0.12,
              width * 0.6,
              20,
            ),
          ],
        );
      },
    );
  }

  Widget _circle(double left, double top, double d, int alpha) {
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: d,
          height: d,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(alpha),
          ),
        ),
      ),
    );
  }
}
