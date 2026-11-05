import 'package:flutter/material.dart';

/// Градиентный фон с плавной сменой палитры и декоративными кругами,
/// смещающимися при листании страниц (параллакс).
class OnboardingBackground extends StatelessWidget {
  final double page;

  const OnboardingBackground({super.key, required this.page});

  static const _top = [Color(0xFF66BB6A), Color(0xFF7E57C2), Color(0xFF42A5F5)];
  static const _bottom = [
    Color(0xFF2E7D32),
    Color(0xFF4527A0),
    Color(0xFF1565C0),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_lerp(_top, page), _lerp(_bottom, page)],
              ),
            ),
          ),
        ),
        _circle(
          left: -w * 0.25 - page * w * 0.2,
          top: h * 0.05,
          d: w * 0.8,
          alpha: 26,
        ),
        _circle(
          left: w * 0.55 - page * w * 0.35,
          top: h * 0.32,
          d: w * 0.7,
          alpha: 20,
        ),
      ],
    );
  }

  Color _lerp(List<Color> colors, double page) {
    final i = page.floor().clamp(0, colors.length - 2);
    return Color.lerp(colors[i], colors[i + 1], (page - i).clamp(0, 1))!;
  }

  Widget _circle({
    required double left,
    required double top,
    required double d,
    required int alpha,
  }) {
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
