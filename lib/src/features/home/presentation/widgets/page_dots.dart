import 'package:flutter/material.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';

/// Точки-индикаторы текущей страницы карусели.
class PageDots extends StatelessWidget {
  final int count;
  final PageController controller;

  const PageDots({super.key, required this.count, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, _) {
          final value = controller.hasClients
              ? (controller.page ?? controller.initialPage.toDouble())
              : controller.initialPage.toDouble();
          final cur = value.round();
          return Row(
            children: [
              for (int i = 0; i < count; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(right: 6),
                  width: i == cur ? 30 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == cur
                        ? AppColors.primary
                        : const Color(0xFFD9DAE6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
