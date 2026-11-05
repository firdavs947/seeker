import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';

/// Заголовок карусели с номером текущей карточки.
class TrendingHeader extends StatelessWidget {
  final int count;
  final PageController controller;

  const TrendingHeader({
    super.key,
    required this.count,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Places for you',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Swipe to explore',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          if (count > 0)
            AnimatedBuilder(
              animation: controller,
              builder: (_, _) {
                final value = controller.hasClients
                    ? (controller.page ?? controller.initialPage.toDouble())
                    : controller.initialPage.toDouble();
                final idx = value.round().clamp(0, count - 1) + 1;
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: idx.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${count.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}
