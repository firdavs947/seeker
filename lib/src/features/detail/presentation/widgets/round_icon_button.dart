import 'package:flutter/material.dart';

/// Круглая белая кнопка с тенью — для верхней панели экрана деталей.
class RoundIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const RoundIconButton({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
