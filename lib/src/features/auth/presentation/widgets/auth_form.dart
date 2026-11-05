import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seeker/src/features/auth/presentation/widgets/auth_mode_switch.dart';
import 'package:seeker/src/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:seeker/src/features/auth/presentation/widgets/auth_social_button.dart';
import 'package:seeker/src/features/auth/presentation/widgets/auth_text_field.dart';

/// Форма авторизации: переключатель режима, поля ввода,
/// основная кнопка, вход через соцсети и подвал с переключением режима.
class AuthForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Color accent;
  final double bottomInset;
  final bool isSignUp;
  final bool loading;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController pass;
  final TextEditingController confirm;
  final ValueChanged<bool> onModeChanged;
  final VoidCallback onSubmit;
  final String? Function(String?) validateName;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final String? Function(String?) validateConfirm;

  const AuthForm({
    super.key,
    required this.formKey,
    required this.accent,
    required this.bottomInset,
    required this.isSignUp,
    required this.loading,
    required this.name,
    required this.email,
    required this.pass,
    required this.confirm,
    required this.onModeChanged,
    required this.onSubmit,
    required this.validateName,
    required this.validateEmail,
    required this.validatePassword,
    required this.validateConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: accent, end: accent),
      duration: const Duration(milliseconds: 500),
      builder: (_, c, _) => _buildForm(c ?? accent),
    );
  }

  Widget _buildForm(Color accent) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + bottomInset),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthModeSwitch(
              isSignUp: isSignUp,
              accent: accent,
              onChanged: onModeChanged,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 24),

            // Username (только Sign Up)
            _expand(
              isSignUp,
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AuthTextField(
                  controller: name,
                  label: 'auth.username'.tr(),
                  icon: Icons.person_rounded,
                  accent: accent,
                  textInputAction: TextInputAction.next,
                  validator: isSignUp ? validateName : null,
                ),
              ),
            ),

            AuthTextField(
              controller: email,
              label: 'auth.email'.tr(),
              icon: Icons.mail_rounded,
              accent: accent,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: validateEmail,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),

            AuthTextField(
              controller: pass,
              label: 'auth.password'.tr(),
              icon: Icons.lock_rounded,
              accent: accent,
              isPassword: true,
              textInputAction: isSignUp
                  ? TextInputAction.next
                  : TextInputAction.done,
              validator: validatePassword,
              onSubmitted: (_) {
                if (!isSignUp) onSubmit();
              },
            ).animate().fadeIn(delay: 480.ms).slideY(begin: 0.2, end: 0),

            // Confirm (только Sign Up)
            _expand(
              isSignUp,
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: AuthTextField(
                  controller: confirm,
                  label: 'auth.confirm_password'.tr(),
                  icon: Icons.lock_outline_rounded,
                  accent: accent,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: isSignUp ? validateConfirm : null,
                  onSubmitted: (_) => onSubmit(),
                ),
              ),
            ),

            // Forgot password (только Sign In)
            _expand(
              !isSignUp,
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: восстановление пароля
                  },
                  child: Text(
                    'auth.forgot_password'.tr(),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: isSignUp ? 28 : 12),

            AuthPrimaryButton(
              label: isSignUp
                  ? 'auth.create_account'.tr()
                  : 'auth.sign_in'.tr(),
              loading: loading,
              accent: accent,
              onTap: onSubmit,
            ).animate().fadeIn(delay: 560.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 26),
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFE6E7F0))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'auth.or_continue_with'.tr(),
                    style: const TextStyle(
                      color: Color(0xFF9A9CB0),
                      fontSize: 13,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFE6E7F0))),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: AuthSocialButton(
                    label: 'Google',
                    leading: const Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFFDB4437),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    onTap: () {
                      // TODO: Google sign in
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AuthSocialButton(
                    label: 'Apple',
                    leading: const Icon(
                      Icons.apple,
                      color: Colors.black87,
                      size: 24,
                    ),
                    onTap: () {
                      // TODO: Apple sign in
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 26),
            Center(
              child: GestureDetector(
                onTap: () => onModeChanged(!isSignUp),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF8A8CA0),
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: isSignUp
                            ? 'auth.have_account'.tr()
                            : 'auth.no_account'.tr(),
                      ),
                      TextSpan(
                        text: isSignUp
                            ? 'auth.sign_in'.tr()
                            : 'auth.sign_up'.tr(),
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Плавное появление/скрытие блока
  Widget _expand(bool show, Widget child) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: show
          ? child.animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0)
          : const SizedBox(width: double.infinity),
    );
  }
}
