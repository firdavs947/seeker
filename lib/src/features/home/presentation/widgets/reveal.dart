import 'package:flutter/material.dart';

/// Плавное появление, когда виджет доскроллили до экрана.
class Reveal extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  final Duration delay;

  const Reveal({
    super.key,
    required this.controller,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  bool _shown = false;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_check);
    super.dispose();
  }

  void _check() {
    if (_shown || _scheduled || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;

    final y = box.localToGlobal(Offset.zero).dy;
    final h = MediaQuery.of(context).size.height;

    if (y < h * 0.95) {
      _scheduled = true;
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => _shown = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _shown ? Offset.zero : const Offset(0, 0.12),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _shown ? 1 : 0,
        duration: const Duration(milliseconds: 650),
        child: widget.child,
      ),
    );
  }
}
