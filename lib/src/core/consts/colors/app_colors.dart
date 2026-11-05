import 'package:flutter/material.dart';

/// Все цвета приложения в одном месте.
class AppColors {
  AppColors._();

  // ---- Бренд ----
  static const Color primary = Color(0xFF673AB7); // фиолетовый
  static const Color primaryDark = Color(0xFF4527A0);
  static const Color primaryLight = Color(0xFF7E57C2);

  static const Color secondary = Color(0xFF1E88E5); // синий
  static const Color secondaryDark = Color(0xFF1565C0);
  static const Color secondaryLight = Color(0xFF42A5F5);

  static const Color green = Color(0xFF66BB6A);
  static const Color greenDark = Color(0xFF2E7D32);

  static const Color accent = Color(0xFFFFB300); // янтарный
  static const Color coral = Color(0xFFFF7A59); // тёплый акцент

  // ---- Фоны и поверхности ----
  static const Color cream = Color(0xFFF7F3EC); // тёплый фон Home
  static const Color background = Color(0xFFF4F5FA);
  static const Color surface = Colors.white;
  static const Color fieldFill = Color(0xFFF4F5FA);
  static const Color border = Color(0xFFE9EAF3);
  static const Color divider = Color(0xFFE6E7F0);

  // ---- Текст ----
  static const Color ink = Color(0xFF14142B); // почти чёрный
  static const Color textPrimary = Color(0xFF1F2033);
  static const Color textSecondary = Color(0xFF8A8CA0);
  static const Color textHint = Color(0xFF9A9CB0);

  // ---- Статусы ----
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF2E7D32);
  static const Color like = Color(0xFFFF4D6D);

  // ---- Тени ----
  static const Color shadow = Color(0x1A1F2033);

  // ---- Градиенты ----
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, secondaryLight],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, secondary],
  );
}
