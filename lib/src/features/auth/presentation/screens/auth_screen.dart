import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker/src/core/router/app_router.dart';
import 'package:seeker/src/core/widgets/language_switcher.dart';
import 'package:seeker/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seeker/src/features/auth/presentation/bloc/auth_event.dart';
import 'package:seeker/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:seeker/src/features/auth/presentation/widgets/auth_background.dart';
import 'package:seeker/src/features/auth/presentation/widgets/auth_card.dart';
import 'package:seeker/src/features/auth/presentation/widgets/auth_flying_items.dart';
import 'package:seeker/src/features/auth/presentation/widgets/auth_form.dart';
import 'package:seeker/src/features/auth/presentation/widgets/auth_header.dart';

const _accentIn = Color(0xFF673AB7);
const _accentUp = Color(0xFF1E88E5);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  late final AnimationController _mode = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    // Синхронизируем анимацию переключателя с текущим режимом блока.
    _mode.value = context.read<AuthBloc>().state.isSignUp ? 1 : 0;
  }

  @override
  void dispose() {
    _mode.dispose();
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _setMode(bool signUp) {
    final bloc = context.read<AuthBloc>();
    if (signUp == bloc.state.isSignUp || bloc.state.isLoading) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    bloc.add(AuthModeChanged(signUp));
    _mode.animateTo(
      signUp ? 1 : 0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  void _submit() {
    final bloc = context.read<AuthBloc>();
    if (bloc.state.isLoading) return;
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.lightImpact();
      return;
    }

    bloc.add(
      AuthSubmitted(
        email: _email.text.trim(),
        username: _name.text.trim(),
        password: _pass.text,
      ),
    );
  }

  /// Переводит известные сообщения сервера и репозиториев.
  /// Остальное показывает как есть.
  String _localizeError(String m) {
    final s = m.toLowerCase();
    if (s.contains('invalid identifier')) {
      return 'errors.invalid_credentials'.tr();
    }
    if (s.contains('already taken')) return 'errors.already_taken'.tr();
    if (s.contains("can't reach") || s.contains('internet')) {
      // в debug оставляем оригинал: в нём виден адрес сервера
      return kDebugMode ? m : 'errors.network'.tr();
    }
    if (s.contains('too long')) return 'errors.timeout'.tr();
    return m;
  }

  void _goHome() {
    // Полный переход на главный экран: стек заменяется (как pushAndRemoveUntil).
    context.goNamed(AppRouteNames.home);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D32),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'auth.welcome'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _showError(String message) {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE53935),
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  String? _vName(String? v) =>
      (v == null || v.trim().length < 3) ? 'validation.min_3'.tr() : null;

  String? _vEmail(String? v) {
    final s = v?.trim() ?? '';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)
        ? null
        : 'validation.email'.tr();
  }

  String? _vPass(String? v) =>
      (v == null || v.length < 6) ? 'validation.min_6'.tr() : null;

  String? _vConfirm(String? v) =>
      v != _pass.text ? 'validation.passwords_match'.tr() : null;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.success:
            HapticFeedback.mediumImpact();
            _goHome();
          case AuthStatus.failure:
            final msg = state.errorMessage;
            _showError(
              msg == null ? 'errors.generic'.tr() : _localizeError(msg),
            );
          case AuthStatus.idle:
          case AuthStatus.loading:
            break;
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isSignUp = state.isSignUp;
          final loading = state.isLoading;
          // Подписка на смену языка: экран перерисуется при context.setLocale(...)
          final lang = context.locale.languageCode;

          final mq = MediaQuery.of(context);
          final w = mq.size.width;
          final h = mq.size.height;
          final hh = h * 0.36; // высота «шапки»
          final keyboard = mq.viewInsets.bottom > 0;
          final topPad = mq.padding.top;
          final accent = isSignUp ? _accentUp : _accentIn;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(
                    child: AuthBackground(
                      animation: _mode,
                      width: w,
                      height: h,
                    ),
                  ),

                  Positioned(
                    left: 28,
                    top: topPad + 64,
                    width: w * 0.58,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: keyboard ? 0 : 1,
                      child: AuthHeader(lang: lang, isSignUp: isSignUp),
                    ),
                  ),

                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: keyboard ? topPad + 12 : hh - 30,
                    child: AuthCard(
                      child: AuthForm(
                        formKey: _formKey,
                        accent: accent,
                        bottomInset: mq.padding.bottom,
                        isSignUp: isSignUp,
                        loading: loading,
                        name: _name,
                        email: _email,
                        pass: _pass,
                        confirm: _confirm,
                        onModeChanged: _setMode,
                        onSubmit: _submit,
                        validateName: _vName,
                        validateEmail: _vEmail,
                        validatePassword: _vPass,
                        validateConfirm: _vConfirm,
                      ),
                    ),
                  ),

                  // Объекты выше карточки; при открытой клавиатуре скрываются.
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: keyboard,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: keyboard ? 0 : 1,
                        child: AuthFlyingItems(
                          animation: _mode,
                          width: w,
                          headerHeight: hh,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                        left: 24,
                        top: topPad + 10,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: keyboard ? 0 : 1,
                          child: IgnorePointer(
                            ignoring: keyboard,
                            child: const LanguageSwitcher(),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideX(begin: -0.3, end: 0, curve: Curves.easeOutCubic),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
