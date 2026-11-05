import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';

/// Язык приложения: код локали, отображаемое имя и флаг.
class AppLanguage {
  final String code;
  final String name;
  final String flag;

  const AppLanguage(this.code, this.name, this.flag);
}

const kAppLanguages = [
  AppLanguage('en', 'English', '🇬🇧'),
  AppLanguage('ru', 'Русский', '🇷🇺'),
  AppLanguage('uz', 'O‘zbekcha', '🇺🇿'),
];

/// Нижнее окно выбора языка.
class LanguageSheet extends StatelessWidget {
  final String current;
  final ValueChanged<String> onPick;

  const LanguageSheet({super.key, required this.current, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'language.title'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < kAppLanguages.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child:
                  _langTile(kAppLanguages[i], kAppLanguages[i].code == current)
                      .animate()
                      .fadeIn(delay: (80 * i + 100).ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
            ),
        ],
      ),
    );
  }

  Widget _langTile(AppLanguage l, bool selected) {
    return GestureDetector(
      onTap: () => onPick(l.code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withAlpha(18)
              : AppColors.fieldFill,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Row(
          children: [
            Text(l.flag, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                l.name,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.ink,
                ),
              ),
            ),
            AnimatedScale(
              scale: selected ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
