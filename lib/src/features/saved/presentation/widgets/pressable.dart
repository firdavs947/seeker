import 'package:flutter/material.dart';

/// Лёгкое «прожатие» при нажатии: обёртка для кнопок и тапабельных блоков.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const Pressable({super.key, required this.child, required this.onTap});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: const Duration(milliseconds: 130),
        child: widget.child,
      ),
    );
  }
}
