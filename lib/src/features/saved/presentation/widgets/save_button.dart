import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/saved/presentation/bloc/saved_bloc.dart';
import 'package:seeker/src/features/saved/presentation/bloc/saved_event.dart';

/// Сердечко «сохранить в кеш».
/// [glass] = true: стеклянное (на фото), false: белый круг с тенью.
/// [onRemove]: если задан, вызывается вместо обычного удаления
/// (нужно, чтобы карточка в Saved плавно схлопнулась).
class SaveButton extends StatelessWidget {
  final Place place;
  final bool glass;
  final double size;
  final Future<void> Function()? onRemove;

  const SaveButton({
    super.key,
    required this.place,
    this.glass = true,
    this.size = 44,
    this.onRemove,
  });

  Future<void> _tap(BuildContext context, bool saved) async {
    HapticFeedback.lightImpact();
    if (saved && onRemove != null) {
      await onRemove!();
      return;
    }
    context.read<SavedBloc>().add(SavedToggleRequested(place));
  }

  @override
  Widget build(BuildContext context) {
    // Перерисовываемся только когда меняется статус именно этого места.
    final saved = context.select(
      (SavedBloc bloc) => bloc.state.isSaved(place.id),
    );

    final icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.elasticOut,
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: Icon(
        saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        key: ValueKey(saved),
        size: size * 0.5,
        color: saved
            ? AppColors.like
            : (glass ? Colors.white : AppColors.textPrimary),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _tap(context, saved),
      child: glass
          ? ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  width: size,
                  height: size,
                  color: Colors.white.withAlpha(60),
                  child: Center(child: icon),
                ),
              ),
            )
          : Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(child: icon),
            ),
    );
  }
}
