import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingPageContent extends StatelessWidget {
  final String title;
  final String description;
  final Color titleColor;
  final Color descriptionColor;

  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.description,
    this.titleColor = Colors.white,
    this.descriptionColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: titleColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: descriptionColor,
                  fontSize: 16,
                  height: 1.5,
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
