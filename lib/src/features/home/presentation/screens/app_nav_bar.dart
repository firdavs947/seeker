import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';

class AppNavItem {
  final IconData icon;
  final String label;

  const AppNavItem({required this.icon, required this.label});
}

/// Плавающий навбар с «жидким» пузырём над выбранной вкладкой.
/// Ставь его поверх контента: Stack + Positioned(bottom: 0, left: 0, right: 0).
class AppNavBar extends StatefulWidget {
  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar> {
  // ---- геометрия ----
  static const double _barH = 70; // высота белой панели
  static const double _overhang = 28; // насколько пузырь выступает над панелью
  static const double _bubble = 64; // размер пузыря
  static const double _iconSize = 26;
  static const double _totalH = _barH + _overhang;
  static const double _selCenterY = 32; // центр иконки в пузыре
  static const double _idleCenterY = _overhang + 31; // центр иконки в покое

  static const Color _idleColor = Color(0xFF7C7E92);

  // «Жидкость»: передний край пузыря быстрый, задний медленный
  static const Duration _leadDur = Duration(milliseconds: 260);
  static const Duration _trailDur = Duration(milliseconds: 560);

  bool _movingRight = true;

  @override
  void didUpdateWidget(covariant AppNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _movingRight = widget.currentIndex > old.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).padding.bottom;
    final bottom = inset > 12 ? inset : 12.0;

    return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, bottom),
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final n = widget.items.length;
              final slotW = w / n;

              final bubbleLeft =
                  slotW * widget.currentIndex + (slotW - _bubble) / 2;
              final leftDur = _movingRight ? _trailDur : _leadDur;
              final rightDur = _movingRight ? _leadDur : _trailDur;

              return SizedBox(
                height: _totalH,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Белая панель
                    Positioned(
                      left: 0,
                      right: 0,
                      top: _overhang,
                      height: _barH,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x261F2033),
                              blurRadius: 30,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Скользящий пузырь (края двигаются с разной скоростью)
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: bubbleLeft),
                      duration: leftDur,
                      curve: Curves.easeOutCubic,
                      builder: (_, left, _) => TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: bubbleLeft + _bubble),
                        duration: rightDur,
                        curve: Curves.easeOutCubic,
                        builder: (_, right, _) => Positioned(
                          left: left,
                          top: 0,
                          width: (right - left).clamp(_bubble, w),
                          height: _bubble,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(_bubble / 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(80),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppColors.buttonGradient,
                                borderRadius: BorderRadius.circular(
                                  _bubble / 2 - 5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Иконки и подписи
                    for (int i = 0; i < n; i++) _slot(i, slotW),
                  ],
                ),
              );
            },
          ),
        )
        .animate()
        .slideY(
          begin: 1.2,
          end: 0,
          delay: 300.ms,
          duration: 700.ms,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(delay: 300.ms);
  }

  Widget _slot(int i, double slotW) {
    final sel = i == widget.currentIndex;
    final item = widget.items[i];

    return Positioned(
      left: slotW * i,
      top: 0,
      width: slotW,
      height: _totalH,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!sel) HapticFeedback.selectionClick();
          widget.onTap(i);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Иконка: в покое по центру панели, выбранная поднимается в пузырь
            AnimatedPositioned(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutBack,
              left: 0,
              right: 0,
              top: (sel ? _selCenterY : _idleCenterY) - _iconSize / 2,
              height: _iconSize,
              child: Center(
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: sel ? Colors.white : _idleColor),
                  duration: const Duration(milliseconds: 300),
                  builder: (_, color, _) => AnimatedScale(
                    scale: sel ? 1.08 : 1,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    child: Icon(item.icon, size: _iconSize, color: color),
                  ),
                ),
              ),
            ),

            // Подпись выбранной вкладки
            Positioned(
              left: 0,
              right: 0,
              bottom: 11,
              child: AnimatedSlide(
                offset: sel ? Offset.zero : const Offset(0, 0.6),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: sel ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
