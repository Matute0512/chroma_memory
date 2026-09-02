/// Modo de accesibilidad visual para personas con daltonismo.
///
/// Según la condición se activan texturas/patrones que diferencian las fichas
/// por geometría, no por color:
/// - Protanopía y deuteranopía confunden rojo/verde.
/// - Tritanopía confunde azul/amarillo.
///
/// Elegir la condición guarda la preferencia del usuario (de cara a poder
/// afinar cada perfil en el futuro); por ahora todas activan el mismo juego de
/// patrones universales, que cubre cualquier deficiencia de una pasada.
enum ColorVisionMode {
  none('Sin filtro', 'Colores normales, sin texturas.'),
  protanopia('Protanopía', 'Dificultad con el rojo/verde.'),
  deuteranopia('Deuteranopía', 'Dificultad con el verde/rojo.'),
  tritanopia('Tritanopía', 'Dificultad con el azul/amarillo.');

  const ColorVisionMode(this.label, this.description);

  final String label;
  final String description;

  /// Si se deben pintar texturas sobre las fichas.
  bool get usesPatterns => this != ColorVisionMode.none;

  static ColorVisionMode fromName(String? name) {
    for (final ColorVisionMode mode in ColorVisionMode.values) {
      if (mode.name == name) return mode;
    }
    return ColorVisionMode.none;
  }
}
