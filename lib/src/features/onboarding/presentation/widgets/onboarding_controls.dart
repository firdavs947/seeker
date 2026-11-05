import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Нижняя панель онбординга: индикатор страниц, кнопка «Skip» и основная
/// кнопка («Next» → «Get Started» на последней странице).
class OnboardingControls extends StatelessWidget {
  final PageController controller;
  final double page;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const OnboardingControls({
    super.key,
    required this.controller,
    required this.page,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = page >= 1.5;

    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Column(
        children: [
          SmoothPageIndicator(
            controller: controller,
            count: 3,
            effect: const ExpandingDotsEffect(
              activeDotColor: Colors.white,
              dotColor: Colors.white54,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 4,
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedOpacity(
                  duration: 300.ms,
                  opacity: isLast ? 0 : 1,
                  child: IgnorePointer(
                    ignoring: isLast,
                    child: TextButton(
                      onPressed: onSkip,
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    child: Text(
                      isLast ? 'Get Started' : 'Next',
                      key: ValueKey(isLast),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
