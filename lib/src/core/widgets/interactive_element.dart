import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Объект: парит, отбрасывает тень, подпрыгивает по тапу, наклоняется в 3D
/// при перетаскивании и пружинно возвращается на место.
class InteractiveElement extends StatefulWidget {
  final Widget child;
  final double floatPhase; // 0..1, чтобы объекты парили не синхронно
  final double floatAmplitude;
  final bool showShadow;

  const InteractiveElement({
    super.key,
    required this.child,
    this.floatPhase = 0,
    this.floatAmplitude = 8,
    this.showShadow = true,
  });

  @override
  State<InteractiveElement> createState() => _InteractiveElementState();
}

class _InteractiveElementState extends State<InteractiveElement>
    with TickerProviderStateMixin {
  late final AnimationController _float;
  late final AnimationController _back;
  late final AnimationController _bounce;

  Offset _drag = Offset.zero;
  Offset _from = Offset.zero;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();

    _float = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 2400 + (widget.floatPhase * 1200).round(),
      ),
    )..repeat(reverse: true);

    _back =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 800),
        )..addListener(() {
          setState(() {
            _drag = Offset.lerp(
              _from,
              Offset.zero,
              Curves.elasticOut.transform(_back.value),
            )!;
          });
        });

    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _float.dispose();
    _back.dispose();
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _bounce.forward(from: 0),
      onPanStart: (_) {
        _back.stop();
        setState(() => _dragging = true);
      },
      onPanUpdate: (d) => setState(() => _drag += d.delta),
      onPanEnd: (_) {
        _from = _drag;
        setState(() => _dragging = false);
        _back.forward(from: 0);
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_float, _bounce]),
        builder: (context, child) {
          final f = Curves.easeInOut.transform(_float.value) * 2 - 1; // -1..1
          final floatY = f * widget.floatAmplitude;

          final b = _bounce.value;
          final bounceScale = 1 + 0.22 * math.sin(math.pi * b);
          final wiggle = math.sin(b * math.pi * 4) * 0.18 * (1 - b);

          // лёгкое покачивание + наклон от пальца (3D)
          final sway = f * 0.10;
          final tiltY = (_drag.dx / 250).clamp(-0.8, 0.8) + sway;
          final tiltX = (-_drag.dy / 250).clamp(-0.8, 0.8);

          // когда объект «выше» — тень меньше
          final shadowK = 0.7 + 0.3 * (f + 1) / 2;

          return Transform.translate(
            offset: _drag + Offset(0, floatY),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (widget.showShadow)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -6,
                    height: 18,
                    child: FractionallySizedBox(
                      widthFactor: 0.6 * shadowK,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.black.withAlpha(36),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0012) // перспектива
                    ..rotateY(tiltY)
                    ..rotateX(tiltX)
                    ..rotateZ(wiggle),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: _dragging ? 1.12 : 1.0),
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    builder: (_, s, c) =>
                        Transform.scale(scale: s * bounceScale, child: c),
                    child: child,
                  ),
                ),
              ],
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
