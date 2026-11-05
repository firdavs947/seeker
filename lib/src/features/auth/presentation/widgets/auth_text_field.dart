import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color accent;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.accent,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;
  bool _hidden = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color c, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: c, width: width),
  );

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFE53935);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: widget.accent.withAlpha(45),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.isPassword && _hidden,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        validator: widget.validator,
        onFieldSubmitted: widget.onSubmitted,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        cursorColor: widget.accent,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2033),
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(color: Color(0xFF8A8CA0)),
          floatingLabelStyle: TextStyle(
            color: widget.accent,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              end: _focused ? widget.accent : const Color(0xFF9A9CB0),
            ),
            duration: const Duration(milliseconds: 250),
            builder: (_, c, _) => Icon(widget.icon, color: c),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _hidden
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: const Color(0xFF9A9CB0),
                  ),
                  onPressed: () => setState(() => _hidden = !_hidden),
                )
              : null,
          filled: true,
          fillColor: _focused ? Colors.white : const Color(0xFFF4F5FA),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
          enabledBorder: _border(const Color(0xFFE9EAF3), 1.2),
          focusedBorder: _border(widget.accent, 1.8),
          errorBorder: _border(red, 1.2),
          focusedErrorBorder: _border(red, 1.8),
        ),
      ),
    );
  }
}
