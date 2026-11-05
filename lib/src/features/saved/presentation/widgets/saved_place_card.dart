import 'package:flutter/material.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/detail/presentation/screens/place_detail_screen.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/home/presentation/widgets/place_image.dart';
import 'package:seeker/src/features/saved/presentation/widgets/save_button.dart';

/// Карточка сохранённого места: фото, категория, название и часы работы.
class SavedPlaceCard extends StatefulWidget {
  final Place place;
  final VoidCallback onRemoved;

  const SavedPlaceCard({
    super.key,
    required this.place,
    required this.onRemoved,
  });

  @override
  State<SavedPlaceCard> createState() => _SavedPlaceCardState();
}

class _SavedPlaceCardState extends State<SavedPlaceCard> {
  bool _down = false;
  bool _gone = false;

  /// Плавно схлопывает карточку, потом удаляет из кеша
  Future<void> _animateOut() async {
    setState(() => _gone = true);
    await Future.delayed(const Duration(milliseconds: 380));
    if (mounted) widget.onRemoved();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final heroTag = 'saved_${place.id}';

    return ClipRect(
      child: AnimatedAlign(
        alignment: Alignment.topCenter,
        heightFactor: _gone ? 0 : 1,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _gone ? 0 : 1,
          duration: const Duration(milliseconds: 250),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _down = true),
              onTapUp: (_) => setState(() => _down = false),
              onTapCancel: () => setState(() => _down = false),
              onTap: () => openPlaceDetails(context, place, heroTag: heroTag),
              child: AnimatedScale(
                scale: _down ? 0.97 : 1,
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: place.colors[1].withAlpha(70),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 190,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Hero(
                            tag: heroTag,
                            child: PlaceImage(place: place, radius: 30),
                          ),
                        ),

                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withAlpha(80),
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withAlpha(170),
                                  ],
                                  stops: const [0, 0.35, 0.5, 1],
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (place.category.isNotEmpty)
                          Positioned(
                            left: 16,
                            top: 16,
                            child: Container(
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
                          ),

                        // Сердечко (плавно убирает карточку)
                        Positioned(
                          right: 14,
                          top: 12,
                          child: SaveButton(
                            place: place,
                            size: 42,
                            onRemove: _animateOut,
                          ),
                        ),

                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 16,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  height: 1.1,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: Colors.white,
                                ),
                              ),
                              if (place.workTime.trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 15,
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
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Красный фон, открывающийся при свайпе карточки влево (удаление).
class SavedDismissBackground extends StatelessWidget {
  const SavedDismissBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 28),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
