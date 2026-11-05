import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';

/// Строка поиска с крутящейся подсказкой и кнопкой фильтра.
class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueNotifier<int> hint;
  final List<String> hints;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.hints,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 58,
        padding: const EdgeInsets.fromLTRB(20, 0, 6, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(29),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x141F2033),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.textHint),
            const SizedBox(width: 12),
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (_, v, _) {
                      if (v.text.isNotEmpty) return const SizedBox.shrink();
                      return IgnorePointer(
                        child: ValueListenableBuilder<int>(
                          valueListenable: hint,
                          builder: (_, i, _) {
                            final text = hints[i % hints.length];
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 450),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.6),
                                        end: Offset.zero,
                                      ).animate(anim),
                                      child: child,
                                    ),
                                  ),
                              child: Align(
                                key: ValueKey(text),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Try “$text”',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  TextField(
                    controller: controller,
                    cursorColor: AppColors.primary,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.buttonGradient,
              ),
              child: const Icon(Icons.tune_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.4, end: 0);
  }
}
