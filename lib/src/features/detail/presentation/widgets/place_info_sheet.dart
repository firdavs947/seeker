import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/home/presentation/widgets/place_image.dart';

/// Выдвижной лист с информацией о месте: категория, название, часы работы,
/// галерея миниатюр и краткая история.
class PlaceInfoSheet extends StatelessWidget {
  final Place place;
  final ScrollController controller;
  final double bottomInset;

  /// Оставляет ли место запас снизу под кнопку «Open in Maps».
  final bool hasMap;

  /// Текущая страница галереи — подсвечивает активную миниатюру.
  final ValueListenable<int> page;
  final ValueChanged<int> onSelectImage;

  const PlaceInfoSheet({
    super.key,
    required this.place,
    required this.controller,
    required this.bottomInset,
    required this.hasMap,
    required this.page,
    required this.onSelectImage,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = (hasMap ? 130.0 : 40.0) + bottomInset;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: ListView(
        controller: controller,
        padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPad),
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (place.category.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(place.icon, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      place.category,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 12),
          Text(
            place.name,
            style: const TextStyle(
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 330.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 20),
          if (place.workTime.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.fieldFill,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.buttonGradient,
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Working hours',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          place.workTime,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 430.ms).slideY(begin: 0.3, end: 0),
          if (place.images.length > 1) ...[
            const SizedBox(height: 26),
            const Text(
              'Gallery',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 520.ms),
            const SizedBox(height: 12),
            SizedBox(
              height: 78,
              child: ValueListenableBuilder<int>(
                valueListenable: page,
                builder: (_, current, _) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: place.images.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => onSelectImage(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 78,
                      height: 78,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: i == current
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: PlaceImage(place: place, radius: 18, index: i),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 580.ms).slideY(begin: 0.2, end: 0),
          ],
          const SizedBox(height: 26),
          const Text(
            'Short history',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 640.ms),
          const SizedBox(height: 10),
          Text(
            place.shortHistory.isEmpty
                ? 'No description yet.'
                : place.shortHistory,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 720.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}
