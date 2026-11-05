import 'package:flutter/material.dart';

/// Кнопка входа через соцсеть с иконкой-лидером и подписью.
class AuthSocialButton extends StatefulWidget {
  final String label;
  final Widget leading;
  final VoidCallback onTap;

  const AuthSocialButton({
    super.key,
    required this.label,
    required this.leading,
    required this.onTap,
  });

  @override
  State<AuthSocialButton> createState() => _AuthSocialButtonState();
}

class _AuthSocialButtonState extends State<AuthSocialButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3E4EE), width: 1.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.leading,
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Color(0xFF1F2033),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
