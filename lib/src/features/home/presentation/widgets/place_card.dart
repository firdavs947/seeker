import 'package:flutter/material.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/detail/presentation/screens/place_detail_screen.dart';
import 'package:seeker/src/features/home/presentation/widgets/place_image.dart';

/// Небольшая карточка места (категория, название, часы работы).
/// [height] задаёт высоту карточки.
/// [heroTag] включает анимацию перехода на экран деталей; на одном экране
/// у каждой карточки он должен быть уникальным.
class PlaceCard extends StatefulWidget {
  final Place place;
  final double height;
  final String? heroTag;

  const PlaceCard({
    super.key,
    required this.place,
    this.height = 260,
    this.heroTag,
  });

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  bool _down = false;
  bool _liked = false;

  void _open() {
    // Переход через go_router (анимация задана в конфиге маршрута).
    openPlaceDetails(context, widget.place);
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    final image = PlaceImage(place: place, radius: 24);

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: _open,
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: widget.heroTag == null
                      ? image
                      : Hero(tag: widget.heroTag!, child: image),
                ),

                // Затемнение сверху и снизу (для читаемости текста)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(110),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withAlpha(110),
                          ],
                          stops: const [0, 0.38, 0.6, 1],
                        ),
                      ),
                    ),
                  ),
                ),

                // Название + категория
                Positioned(
                  left: 14,
                  top: 14,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(color: Color(0x66000000), blurRadius: 6),
                          ],
                        ),
                      ),
                      if (place.category.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _CategoryPill(text: place.category, icon: place.icon),
                      ],
                    ],
                  ),
                ),

                // Часы работы внизу слева
                if (place.workTime.trim().isNotEmpty)
                  Positioned(
                    left: 14,
                    right: 56,
                    bottom: 16,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            place.workTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Сердечко
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: GestureDetector(
                    onTap: () => setState(() => _liked = !_liked),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _liked
                            ? Colors.white
                            : Colors.white.withAlpha(70),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.elasticOut,
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          _liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(_liked),
                          size: 20,
                          color: _liked ? AppColors.like : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String text;
  final IconData icon;

  const _CategoryPill({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(225),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
