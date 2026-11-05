import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:seeker/src/features/profile/repo/profile_repository.dart';

/// Шапка профиля: градиентный фон с параллаксом, аватар и данные пользователя.
class ProfileHeader extends StatelessWidget {
  final MediaQueryData mq;
  final UserProfile? profile;
  final bool skeleton;
  final ScrollController scroll;

  const ProfileHeader({
    super.key,
    required this.mq,
    required this.profile,
    required this.skeleton,
    required this.scroll,
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.vertical(bottom: Radius.circular(44));

    final name = profile?.username ?? '';
    final letter = name.isEmpty ? '?' : name[0].toUpperCase();

    final content = Padding(
      padding: EdgeInsets.fromLTRB(24, mq.padding.top + 18, 24, 34),
      child: Column(
        children: [
          Text(
            'profile.title'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 26),
          ProfileAvatar(letter: letter),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: skeleton
                ? _HeaderSkeleton(
                    width: 150,
                    height: 28,
                    key: const ValueKey('n_sk'),
                  )
                : Text(
                    name.isEmpty ? '—' : name,
                    key: const ValueKey('n'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: skeleton
                ? _HeaderSkeleton(
                    width: 200,
                    height: 18,
                    key: const ValueKey('e_sk'),
                  )
                : Text(
                    profile?.email ?? '',
                    key: const ValueKey('e'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14.5,
                    ),
                  ),
          ).animate().fadeIn(delay: 380.ms),
          if (profile?.createdAt != null) ...[
            const SizedBox(height: 16),
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(46),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'profile.member_since'.tr(
                          namedArgs: {'date': _fmt(profile!.createdAt!)},
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 150.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  curve: Curves.easeOutBack,
                ),
          ],
        ],
      ),
    );

    return AnimatedBuilder(
      animation: scroll,
      child: content,
      builder: (_, child) {
        // Параллакс декоративных кругов при прокрутке.
        final off = scroll.hasClients ? scroll.offset.clamp(0.0, 300.0) : 0.0;

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: radius,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                Positioned(
                  left: -70,
                  top: -50 - off * 0.35,
                  child: _Blob(size: 230, alpha: 30)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(
                        begin: -8,
                        end: 8,
                        duration: 3.seconds,
                        curve: Curves.easeInOut,
                      ),
                ),
                Positioned(
                  right: -60,
                  top: 90 - off * 0.2,
                  child: _Blob(size: 180, alpha: 24)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(
                        begin: 10,
                        end: -10,
                        duration: 3.5.seconds,
                        curve: Curves.easeInOut,
                      ),
                ),
                child!,
              ],
            ),
          ),
        );
      },
    );
  }
}

String _fmt(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

class _Blob extends StatelessWidget {
  final double size;
  final int alpha;

  const _Blob({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(alpha),
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  final double width;
  final double height;

  const _HeaderSkeleton({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(60),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withAlpha(120));
  }
}
