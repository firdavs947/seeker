import 'package:flutter/material.dart';
import 'package:seeker/src/features/home/model/place.dart';

/// Фото места (по ссылке из Strapi). Пока грузится или фото нет,
/// показывается градиент с иконкой категории.
/// [index] выбирает фото из Place.images, [shift] даёт параллакс в карусели.
class PlaceImage extends StatelessWidget {
  final Place place;
  final double radius;
  final double shift;
  final bool parallax;
  final int index;

  const PlaceImage({
    super.key,
    required this.place,
    this.radius = 0,
    this.shift = 0,
    this.parallax = false,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final url = index < place.images.length ? place.images[index] : null;
    final colors = place.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
          ),
          Positioned(
            right: -24 - shift * 60,
            bottom: 70,
            child: Icon(
              place.icon,
              size: 190,
              color: Colors.white.withAlpha(46),
            ),
          ),
          Positioned(
            left: -50 + shift * 40,
            top: 90,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(22),
              ),
            ),
          ),
          if (url != null)
            Transform.translate(
              offset: Offset(parallax ? -shift * 30 : 0, 0),
              child: Transform.scale(
                scale: parallax ? 1.2 : 1,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  cacheWidth: 900,
                  gaplessPlayback: true,
                  frameBuilder: (context, child, frame, wasSyncLoaded) {
                    if (wasSyncLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                  errorBuilder: (_, error, _) {
                    debugPrint('image error: $url | $error');
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
