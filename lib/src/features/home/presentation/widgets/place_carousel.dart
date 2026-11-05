import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/detail/presentation/screens/place_detail_screen.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/home/presentation/widgets/place_image.dart';
import 'package:seeker/src/features/home/presentation/widgets/pressable.dart';
import 'package:seeker/src/features/saved/presentation/widgets/save_button.dart';

/// 3D-карусель карточек мест.
class PlaceCarousel extends StatelessWidget {
  final List<Place> places;
  final PageController controller;
  final String category;

  const PlaceCarousel({
    super.key,
    required this.places,
    required this.controller,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          height: 430,
          child: PageView.builder(
            key: ValueKey(category),
            controller: controller,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: places.length,
            itemBuilder: (_, i) {
              return AnimatedBuilder(
                animation: controller,
                builder: (_, _) {
                  final value = controller.hasClients
                      ? (controller.page ?? controller.initialPage.toDouble())
                      : controller.initialPage.toDouble();
                  final d = (i - value).clamp(-1.0, 1.0);
                  final t = d.abs();

                  return Transform.translate(
                    offset: Offset(0, t * 28),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateY(-d * 0.45),
                      child: Transform.scale(
                        scale: 1 - t * 0.1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _TrendCard(place: places[i], index: i, d: d),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        )
        .animate()
        .fadeIn(delay: 700.ms, duration: 600.ms)
        .slideX(
          begin: 0.25,
          end: 0,
          curve: Curves.easeOutCubic,
          duration: 800.ms,
        );
  }
}

class _TrendCard extends StatelessWidget {
  final Place place;
  final int index;
  final double d;

  const _TrendCard({required this.place, required this.index, required this.d});

  @override
  Widget build(BuildContext context) {
    final glowColor = place.colors[1];

    return Pressable(
      scale: 0.97,
      onTap: () => openPlaceDetails(context, place),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: glowColor.withAlpha(90),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'place_${place.id}',
                child: PlaceImage(place: place, shift: d, parallax: true),
              ),
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x59000000),
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0xCC000000),
                      ],
                      stops: [0, 0.3, 0.5, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 14,
                child: Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 58,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1.5
                      ..color = Colors.white.withAlpha(210),
                  ),
                ),
              ),
              Positioned(right: 16, top: 18, child: SaveButton(place: place)),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (place.category.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          place.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: place.workTime.trim().isEmpty
                              ? const SizedBox.shrink()
                              : Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        place.workTime,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.north_east_rounded,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
