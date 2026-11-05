import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';
import 'package:seeker/src/core/network/token_storage.dart';
import 'package:seeker/src/core/router/app_router.dart';
import 'package:seeker/src/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:seeker/src/features/profile/presentation/bloc/profile_event.dart';
import 'package:seeker/src/features/profile/presentation/bloc/profile_state.dart';
import 'package:seeker/src/features/profile/presentation/widgets/language_sheet.dart';
import 'package:seeker/src/features/profile/presentation/widgets/logout_button.dart';
import 'package:seeker/src/features/profile/presentation/widgets/logout_dialog.dart';
import 'package:seeker/src/features/profile/presentation/widgets/profile_error_banner.dart';
import 'package:seeker/src/features/profile/presentation/widgets/profile_header.dart';
import 'package:seeker/src/features/profile/presentation/widgets/profile_toggle.dart';
import 'package:seeker/src/features/profile/presentation/widgets/settings_card.dart';
import 'package:seeker/src/features/profile/presentation/widgets/settings_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scroll = ScrollController();

  bool _notif = true;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileRequested());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Запускает перезагрузку профиля и ждёт завершения — для RefreshIndicator.
  Future<void> _load() {
    final bloc = context.read<ProfileBloc>();
    bloc.add(const ProfileRequested());
    return bloc.stream.firstWhere((s) => !s.isLoading);
  }

  void _copy(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          duration: const Duration(milliseconds: 1400),
          margin: const EdgeInsets.fromLTRB(60, 0, 60, 120),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'profile.copied'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _showLanguages() {
    HapticFeedback.selectionClick();
    final current = context.locale.languageCode;
    final screenContext = context;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => LanguageSheet(
        current: current,
        onPick: (code) {
          Navigator.of(ctx).pop();
          screenContext.setLocale(Locale(code));
        },
      ),
    );
  }

  Future<bool> _confirmLogout() async {
    final res = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'logout',
      barrierColor: Colors.black.withAlpha(110),
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (_, _, _) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: const LogoutDialog(),
          ),
        ),
      ),
      transitionBuilder: (_, anim, _, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
    return res ?? false;
  }

  Future<void> _logout() async {
    if (!await _confirmLogout()) return;
    HapticFeedback.mediumImpact();
    await TokenStorage.clear();
    if (!mounted) return;

    // Переход на экран входа (стек заменяется); плавный fade — в конфиге роутера.
    context.goNamed(AppRouteNames.auth);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final current = kAppLanguages.firstWhere(
      (l) => l.code == lang,
      orElse: () => kAppLanguages.first,
    );

    final mq = MediaQuery.of(context);

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final p = state.profile;
        final skeleton = state.isLoading && p == null;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: AppColors.cream,
            body: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: Colors.white,
              edgeOffset: mq.padding.top + 10,
              onRefresh: _load,
              child: SingleChildScrollView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: 130 + mq.padding.bottom),
                child: Column(
                  children: [
                    ProfileHeader(
                      mq: mq,
                      profile: p,
                      skeleton: skeleton,
                      scroll: _scroll,
                    ),
                    if (state.hasFailed) ProfileErrorBanner(onRetry: _load),
                    const SizedBox(height: 26),
                    SettingsCard(
                      title: 'profile.account'.tr(),
                      delay: 450,
                      rows: [
                        SettingsTile(
                          icon: Icons.person_rounded,
                          tint: AppColors.primary,
                          label: 'profile.username'.tr(),
                          value: skeleton ? null : (p?.username ?? '—'),
                          trailing: const Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: AppColors.textHint,
                          ),
                          onTap: () => _copy(p?.username ?? ''),
                        ),
                        SettingsTile(
                          icon: Icons.mail_rounded,
                          tint: AppColors.secondary,
                          label: 'profile.email'.tr(),
                          value: skeleton ? null : (p?.email ?? '—'),
                          trailing: const Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: AppColors.textHint,
                          ),
                          onTap: () => _copy(p?.email ?? ''),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SettingsCard(
                      title: 'profile.settings'.tr(),
                      delay: 560,
                      rows: [
                        SettingsTile(
                          icon: Icons.language_rounded,
                          tint: AppColors.coral,
                          label: 'profile.language'.tr(),
                          value: current.name,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                current.flag,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textHint,
                              ),
                            ],
                          ),
                          onTap: _showLanguages,
                        ),
                        SettingsTile(
                          icon: Icons.notifications_rounded,
                          tint: AppColors.accent,
                          label: 'profile.notifications'.tr(),
                          value: _notif
                              ? 'profile.on'.tr()
                              : 'profile.off'.tr(),
                          trailing: ProfileToggle(
                            value: _notif,
                            onChanged: (v) {
                              HapticFeedback.selectionClick();
                              setState(() => _notif = v);
                            },
                          ),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _notif = !_notif);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    LogoutButton(onTap: _logout),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
