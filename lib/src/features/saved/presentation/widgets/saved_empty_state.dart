import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/saved/presentation/widgets/pressable.dart';

/// Пустое состояние списка сохранённых мест.
class SavedEmptyState extends StatelessWidget {
  /// Нижний отступ (учёт системных вставок).
  final double bottomInset;

  /// Нажатие «Explore places» (переключить на Home).
  final VoidCallback? onExplore;

  const SavedEmptyState({super.key, required this.bottomInset, this.onExplore});

  @override
  Widget build(BuildContext context) {
    Widget ring(int delayMs) =>
        Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withAlpha(90),
                  width: 2,
                ),
              ),
            )
            .animate(delay: delayMs.ms, onPlay: (c) => c.repeat())
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.5, 1.5),
              duration: 2.seconds,
              curve: Curves.easeOut,
            )
            .fade(begin: 0.8, end: 0, duration: 2.seconds);

    return Padding(
      padding: EdgeInsets.fromLTRB(40, 0, 40, 120 + bottomInset),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ring(0),
                ring(1000),
                Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.headerGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(90),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(
                      begin: -6,
                      end: 6,
                      duration: 2.seconds,
                      curve: Curves.easeInOut,
                    ),
              ],
            ),
          ).animate().scale(
            begin: const Offset(0.5, 0.5),
            duration: 800.ms,
            curve: Curves.elasticOut,
          ),
          const SizedBox(height: 26),
          Text(
            'saved.empty_title'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.ink,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 10),
          Text(
            'saved.empty_message'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
          if (onExplore != null) ...[
            const SizedBox(height: 28),
            Pressable(
              onTap: onExplore!,
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withAlpha(90),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.explore_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      'saved.explore'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.4, end: 0),
          ],
        ],
      ),
    );
  }
}
