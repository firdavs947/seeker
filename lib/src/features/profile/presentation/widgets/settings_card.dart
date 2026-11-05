import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';

/// Карточка-секция с заголовком и списком строк, разделённых отступами.
class SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  final int delay;

  const SettingsCard({
    super.key,
    required this.title,
    required this.rows,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F1F2033),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(27),
                  child: Material(
                    color: Colors.white,
                    child: Column(
                      children: [
                        for (int i = 0; i < rows.length; i++) ...[
                          if (i > 0)
                            const Padding(
                              padding: EdgeInsets.only(left: 76),
                              child: Divider(
                                height: 1,
                                color: AppColors.divider,
                              ),
                            ),
                          rows[i],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: delay.ms, duration: 500.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}
