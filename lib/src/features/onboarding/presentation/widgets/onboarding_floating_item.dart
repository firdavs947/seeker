import 'package:flutter/material.dart';
import 'package:seeker/src/core/widgets/interactive_element.dart';
import 'package:seeker/src/features/onboarding/presentation/model/onboarding_item.dart';

/// false — jpg показываются как скруглённые карточки с рамкой и тенью.
/// true  — для PNG без фона: объект парит сам по себе.
const bool kCutoutImages = false;

/// Один парящий объект с параллаксом и 3D-поворотом при листании страниц.
class OnboardingFloatingItem extends StatelessWidget {
  final int index;
  final OnboardingItem item;
  final double page;
  final double w;
  final double h;

  const OnboardingFloatingItem({
    super.key,
    required this.index,
    required this.item,
    required this.page,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    final d = item.page - page; // <0 — ушёл влево, >0 — ещё справа
    final t = (1 - d.abs()).clamp(0.0, 1.0);

    final opacity = Curves.easeOut.transform(t);
    final scale = 0.5 + 0.5 * Curves.easeOutBack.transform(t);
    final size = item.size * w;

    return Positioned(
      key: ValueKey('item_$index'),
      left: item.x * w + d * w * item.depth,
      top: item.y * h,
      child: IgnorePointer(
        ignoring: t < 0.6,
        child: Opacity(
          opacity: opacity,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012) // перспектива 3D-поворота
              ..rotateY(d * 1.1)
              ..rotateX(d * 0.25),
            child: Transform.scale(
              scale: scale,
              child: InteractiveElement(
                floatPhase: item.phase,
                showShadow: kCutoutImages, // у карточек своя тень
                child: _buildImage(context, size),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, double size) {
    final dpr = MediaQuery.of(context).devicePixelRatio;

    final img = item.image.image(
      width: size,
      height: size,
      fit: kCutoutImages ? BoxFit.contain : BoxFit.cover,
      cacheWidth: (size * dpr).round(),
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        color: Colors.white.withAlpha(40),
        child: Icon(item.icon, color: Colors.white, size: size * 0.5),
      ),
    );

    if (kCutoutImages) return img;

    final radius = size * 0.22;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 3),
        child: img,
      ),
    );
  }
}
