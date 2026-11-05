import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';

/// Аватар с вращающимся градиентным кольцом.
///
/// Тап перезапускает вступительную анимацию масштаба.
class ProfileAvatar extends StatefulWidget {
  final String letter;

  const ProfileAvatar({super.key, required this.letter});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  int _taps = 0;

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() => _taps++);
          },
          child: SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(60),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _ring,
                  builder: (_, _) => Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        transform: GradientRotation(_ring.value * 2 * math.pi),
                        colors: const [
                          AppColors.coral,
                          AppColors.accent,
                          Colors.white,
                          AppColors.secondaryLight,
                          AppColors.coral,
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 116,
                  height: 116,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 106,
                  height: 106,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.buttonGradient,
                  ),
                  child: Text(
                    widget.letter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(key: ValueKey(_taps))
        .scale(
          begin: const Offset(0.86, 0.86),
          end: const Offset(1, 1),
          duration: 800.ms,
          curve: Curves.elasticOut,
        );
  }
}
