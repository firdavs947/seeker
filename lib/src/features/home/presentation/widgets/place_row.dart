import 'package:flutter/material.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/detail/presentation/screens/place_detail_screen.dart';
import 'package:seeker/src/features/home/model/place.dart';
import 'package:seeker/src/features/home/presentation/widgets/place_image.dart';
import 'package:seeker/src/features/home/presentation/widgets/pressable.dart';

/// Строка места в списке «All places».
class PlaceRow extends StatelessWidget {
  final Place place;

  const PlaceRow({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => openPlaceDetails(context, place),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F1F2033),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: PlaceImage(place: place, radius: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (place.category.isNotEmpty)
                    Row(
                      children: [
                        Icon(place.icon, size: 15, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          place.category,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  if (place.workTime.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            place.workTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.fieldFill,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
