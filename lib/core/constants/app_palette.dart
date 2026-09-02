import 'package:flutter/material.dart';

/// Tokens de la identidad Chroma Memory — Dark Cyber-Minimal.
///
/// Referencia visual: `design/style_guide.html` (fuera de git).
/// Los nombres semánticos (no de color) son los que se usan en el código.
abstract final class AppPalette {
  // ---- Superficies (negros orgánicos con sesgo azul) ----
  /// Fondo raíz de la app.
  static const Color voidBg = Color(0xFF070B14);

  /// Ambient superior tenue que acompaña el header.
  static const Color ambientTop = Color(0xFF101A33);

  /// Planos: tarjetas y paneles.
  static const Color surface = Color(0xFF0D1526);

  /// Controles elevados / ghost.
  static const Color raised = Color(0xFF141E33);

  /// Estado presionado.
  static const Color pressed = Color(0xFF1B2842);

  /// Relleno de inputs / planos altos.
  static const Color surfaceHigh = Color(0xFF1F2B44);

  /// Scrim de overlays.
  static const Color scrim = Color(0xAA000000);

  /// Bordes finos entre planos (blanco al 8%).
  static const Color hairline = Color(0x14FFFFFF);

  /// Borde fuerte: foco / inputs activos (blanco al 18%).
  static const Color lineStrong = Color(0x2EFFFFFF);

  // ---- Texto (escala de valor) ----
  static const Color textHigh = Color(0xFFF2F5FF);
  static const Color textMid = Color(0xFF9AA6C0);
  static const Color textLow = Color(0xFF5A6580);

  /// Texto sobre acentos vivos (violeta, cyan…).
  static const Color onAccent = Color(0xFF0C1020);

  // ---- UI chrome ----
  static const Color brand = Color(0xFF7C6CFF);
  static const Color brandBright = Color(0xFF9E8FFF);
  static const Color brandDeep = Color(0xFF5A47E8);
  static const Color cyan = Color(0xFF4EE3FF);
  static const Color magenta = Color(0xFFFF5CC8);

  // Semánticos (separados del acento de marca)
  static const Color mint = Color(0xFF3FE0A8); // acierto / éxito / récord
  static const Color coral = Color(0xFFFF5A6E); // error
  static const Color amber = Color(0xFFFFC24B); // avisos
  static const Color gold = Color(0xFFFFD466); // nuevo récord

  /// Gradiente de acción principal (#8B7CFF → #4D7CFF).
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF8B7CFF), Color(0xFF4D7CFF)],
  );

  // ---- Fichas del juego (color base + glow del destello) ----
  static const Color tileEmber = Color(0xFFFF4465);
  static const Color glowEmber = Color(0xFFFF8CA2);
  static const Color tileMint = Color(0xFF1AD6A0);
  static const Color glowMint = Color(0xFF79FFD8);
  static const Color tileAzure = Color(0xFF2E9DFF);
  static const Color glowAzure = Color(0xFF9BD3FF);
  static const Color tileAmber = Color(0xFFFFB01F);
  static const Color glowAmber = Color(0xFFFFE191);

  // ---- Tipografías ----
  /// Display: títulos, marca y puntaje (variable, eje wght).
  static const String fontDisplay = 'Unbounded';

  /// UI y cuerpo.
  static const String fontUi = 'Manrope';

  /// Halo de un color: regla de la luz (el glow viene del color del elemento).
  static List<BoxShadow> glow(
    Color color, {
    double blur = 24,
    double spread = 0,
    double alpha = 0.30,
  }) {
    return <BoxShadow>[
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: blur,
        spreadRadius: spread,
        offset: Offset.zero,
      ),
    ];
  }
}
