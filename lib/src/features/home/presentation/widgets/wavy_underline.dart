import 'package:flutter/material.dart';
import 'package:seeker/src/core/consts/colors/app_colors.dart';

/// Волнистое подчёркивание, которое «рисуется».
class WavyUnderline extends StatefulWidget {
  const WavyUnderline({super.key});

  @override
  State<WavyUnderline> createState() => _WavyUnderlineState();
}

class _WavyUnderlineState extends State<WavyUnderline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => CustomPaint(
        painter: _WavePainter(
          Curves.easeInOut.transform(_c.value),
          AppColors.coral,
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _WavePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const waves = 6;
    final seg = size.width / waves;
    final mid = size.height / 2;

    final path = Path()..moveTo(0, mid);
    for (int i = 0; i < waves; i++) {
      path.quadraticBezierTo(
        seg * i + seg / 2,
        i.isEven ? 0 : size.height,
        seg * (i + 1),
        mid,
      );
    }

    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.progress != progress;
}
