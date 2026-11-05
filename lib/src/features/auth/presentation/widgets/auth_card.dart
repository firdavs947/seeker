import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Белая карточка, в которую «въезжает» форма авторизации.
class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            child: child,
          ),
        )
        .animate()
        .slideY(
          begin: 0.3,
          end: 0,
          duration: 800.ms,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: 500.ms);
  }
}
