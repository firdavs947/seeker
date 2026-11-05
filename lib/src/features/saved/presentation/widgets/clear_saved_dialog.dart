import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/saved/presentation/widgets/pressable.dart';

/// Диалог подтверждения полной очистки списка сохранённых мест.
/// Возвращает `true`, если пользователь подтвердил.
class ClearSavedDialog extends StatelessWidget {
  const ClearSavedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.like.withAlpha(24),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.heart_broken_rounded,
                color: AppColors.like,
                size: 32,
              ),
            ).animate().scale(
              begin: const Offset(0, 0),
              delay: 100.ms,
              duration: 700.ms,
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 18),
            Text(
              'saved.clear_title'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'saved.clear_message'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: 'profile.cancel'.tr(),
                    filled: false,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: 'saved.clear'.tr(),
                    filled: true,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.error : AppColors.fieldFill,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            color: filled ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
