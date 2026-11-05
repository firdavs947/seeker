import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/home/model/place.dart';

/// Круглые чипы категорий с горизонтальной прокруткой.
class HomeCategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const HomeCategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (_, i) {
          final name = categories[i];
          final active = name == selected;

          return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(name),
                child: SizedBox(
                  width: 68,
                  child: Column(
                    children: [
                      AnimatedScale(
                        scale: active ? 1.08 : 1,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutBack,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: active ? AppColors.headerGradient : null,
                            color: active ? null : Colors.white,
                            border: Border.all(
                              color: active
                                  ? Colors.transparent
                                  : AppColors.border,
                              width: 1.4,
                            ),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(80),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : const [],
                          ),
                          child: Icon(
                            categoryIcon(name),
                            size: 26,
                            color: active
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: active
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: active
                              ? AppColors.ink
                              : AppColors.textSecondary,
                        ),
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: (70 * i + 500).ms)
              .scale(begin: const Offset(0.6, 0.6), curve: Curves.easeOutBack);
        },
      ),
    );
  }
}
