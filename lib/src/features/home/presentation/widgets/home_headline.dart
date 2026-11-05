import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/home/presentation/widgets/wavy_underline.dart';

/// Крупный заголовок «Where will you wander next?».
class HomeHeadline extends StatelessWidget {
  const HomeHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 40,
      height: 1.08,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.2,
      color: AppColors.ink,
    );

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Where will you', style: style)
                  .animate()
                  .fadeIn(delay: 150.ms)
                  .slideY(begin: 0.4, end: 0, curve: Curves.easeOutCubic),
              Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ShaderMask(
                            shaderCallback: (rect) =>
                                AppColors.buttonGradient.createShader(rect),
                            child: Text(
                              'wander',
                              style: style.copyWith(color: Colors.white),
                            ),
                          ),
                          const Positioned(
                            left: 2,
                            right: 2,
                            bottom: -6,
                            height: 10,
                            child: WavyUnderline(),
                          ),
                        ],
                      ),
                      const Text(' next?', style: style),
                    ],
                  )
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideY(begin: 0.4, end: 0, curve: Curves.easeOutCubic),
            ],
          ),
        ),
        Positioned(
          right: 22,
          top: 2,
          child:
              Transform.rotate(
                    angle: -0.35,
                    child: const Icon(
                      Icons.flight_rounded,
                      size: 38,
                      color: AppColors.coral,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(
                    begin: -5,
                    end: 5,
                    duration: 2.seconds,
                    curve: Curves.easeInOut,
                  )
                  .animate()
                  .fadeIn(delay: 700.ms)
                  .slideX(begin: -1.5, end: 0, curve: Curves.easeOutCubic),
        ),
      ],
    );
  }
}
