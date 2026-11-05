import 'package:flutter/material.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/home/presentation/widgets/pressable.dart';

const _cardPalettes = <List<Color>>[
  [AppColors.primary, AppColors.secondaryLight],
  [AppColors.coral, AppColors.accent],
  [AppColors.greenDark, AppColors.secondary],
  [AppColors.primaryDark, AppColors.coral],
];

/// Крупные карточки категорий с количеством мест.
class CategoryCards extends StatelessWidget {
  final List<String> categories;
  final List<Place> allPlaces;
  final ScrollController scroll;
  final ValueChanged<String> onSelect;

  const CategoryCards({
    super.key,
    required this.categories,
    required this.allPlaces,
    required this.scroll,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final names = categories.where((c) => c != 'All').toList();

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: names.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final name = names[i];
          final colors = _cardPalettes[i % _cardPalettes.length];
          final count = allPlaces
              .where((p) => p.category.trim() == name)
              .length;

          return Transform.rotate(
            angle: i.isEven ? -0.02 : 0.02,
            child: Pressable(
              onTap: () {
                onSelect(name);
                scroll.animateTo(
                  0,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                );
              },
              child: Container(
                width: 210,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.first.withAlpha(90),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: -24,
                        child: Transform.rotate(
                          angle: -0.3,
                          child: Icon(
                            categoryIcon(name),
                            size: 140,
                            color: Colors.white.withAlpha(60),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(50),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                count == 1 ? '1 place' : '$count places',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 26,
                                height: 1.05,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
