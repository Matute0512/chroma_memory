import 'package:flutter/material.dart';

/// Paleta y temas de la aplicación (Material 3).
///
/// ChromaMemory gira en torno al color, así que la marca se define como un
/// violeta semilla y se deja que Material derive el resto del `ColorScheme`
/// para cada brillo. Los colores de las fichas de juego se definen aparte
/// (shared/domain/entities/color_block.dart) porque son semánticos del juego,
/// no del tema.
abstract final class AppTheme {
  /// Color semilla de la marca (se usa para derivar los ColorScheme).
  static const Color brand = Color(0xFF6C5CE7);

  /// Tema claro.
  static ThemeData get light => _build(Brightness.light);

  /// Tema oscuro.
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}
