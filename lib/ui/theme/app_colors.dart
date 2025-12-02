import 'package:flutter/material.dart';

/// Paleta suave y amigable para PawGram
class AppColors {
  AppColors._();

  // Core palette (user-provided)
  static const Color paddingtonBlue = Color(0xFF1F3A8A); // Azul Paddington
  static const Color softBrown = Color(0xFFA67C52); // Café suave
  static const Color softRed = Color(0xFFD64550); // Rojo suave
  static const Color cream = Color(0xFFFAF7F2); // Blanco crema

  // Accents / utility colors
  static const Color onPaddington = Color(0xFFFFFFFF);
  static const Color onCream = Color(0xFF172127); // texto oscuro suave
  static const Color muted = Color(0xFF6B6B6B);

  // Gentle MaterialColor swatch for paddingtonBlue (soft tints)
  static const MaterialColor paddingtonSwatch = MaterialColor(
    0xFF1F3A8A,
    <int, Color>{
      50: Color(0xFFEFF2FB),
      100: Color(0xFFDCE4F7),
      200: Color(0xFFB9CCEF),
      300: Color(0xFF95B4E7),
      400: Color(0xFF7FA6E2),
      500: paddingtonBlue,
      600: Color(0xFF1A3578),
      700: Color(0xFF172C64),
      800: Color(0xFF122053),
      900: Color(0xFF0E173F),
    },
  );
}
