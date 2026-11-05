import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Точки-индикаторы галереи: активная растягивается в «пилюлю».
class GalleryDots extends StatelessWidget {
  final ValueListenable<int> page;
  final int count;

  const GalleryDots({super.key, required this.page, required this.count});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: page,
      builder: (_, current, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == current ? 24 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: i == current
                    ? Colors.white
                    : Colors.white.withAlpha(120),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}
