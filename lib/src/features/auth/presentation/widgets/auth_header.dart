import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Заголовок и подзаголовок в шапке экрана авторизации.
class AuthHeader extends StatelessWidget {
  final String lang;
  final bool isSignUp;

  const AuthHeader({super.key, required this.lang, required this.isSignUp});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topLeft,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey('$isSignUp-$lang'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSignUp
                ? 'auth.create_account_title'.tr()
                : 'auth.welcome_back'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.1,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isSignUp
                ? 'auth.subtitle_sign_up'.tr()
                : 'auth.subtitle_sign_in'.tr(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
