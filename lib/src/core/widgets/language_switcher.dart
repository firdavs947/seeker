import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';

class _Lang {
  final String code;
  final String name;
  final String flag;

  const _Lang(this.code, this.name, this.flag);
}

const _langs = [
  _Lang('en', 'English', '🇬🇧'),
  _Lang('ru', 'Русский', '🇷🇺'),
  _Lang('uz', 'O‘zbekcha', '🇺🇿'),
];

/// Красивая «таблетка» выбора языка с выпадающим меню.
/// [onDark] = true для цветного фона (белый текст), false для светлого.
class LanguageSwitcher extends StatelessWidget {
  final bool onDark;

  const LanguageSwitcher({super.key, this.onDark = true});

  @override
  Widget build(BuildContext context) {
    final current = context.locale.languageCode;
    final lang = _langs.firstWhere(
      (l) => l.code == current,
      orElse: () => _langs.first,
    );

    final fg = onDark ? Colors.white : AppColors.ink;

    return PopupMenuButton<String>(
      tooltip: 'language.title'.tr(),
      offset: const Offset(0, 54),
      color: Colors.white,
      elevation: 10,
      shadowColor: const Color(0x401F2033),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      onSelected: (code) {
        HapticFeedback.selectionClick();
        context.setLocale(Locale(code));
      },
      itemBuilder: (_) => [
        for (final l in _langs)
          PopupMenuItem<String>(
            value: l.code,
            height: 54,
            child: Row(
              children: [
                Text(l.flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: l.code == current
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: l.code == current
                          ? AppColors.primary
                          : AppColors.ink,
                    ),
                  ),
                ),
                if (l.code == current)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
        decoration: BoxDecoration(
          color: onDark ? Colors.white.withAlpha(46) : AppColors.fieldFill,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: onDark ? Colors.white.withAlpha(90) : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                lang.flag,
                key: ValueKey(lang.code),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              lang.code.toUpperCase(),
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: fg,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: fg),
          ],
        ),
      ),
    );
  }
}
