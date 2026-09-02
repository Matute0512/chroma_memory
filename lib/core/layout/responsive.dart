import 'package:flutter/material.dart';

/// Reglas de layout responsivo de Chroma Memory (Punto 2).
///
/// Principios:
/// - **Columna estrecha legible**: el contenido se centra con un ancho máximo
///   de lectura; en pantallas angostas el viewport ya lo limita solo.
/// - **Aspect ratio bloqueado**: la grilla de juego es siempre 1:1 y ocupa el
///   cuadrado más grande que cabe en su área (LayoutBuilder en ClassicGrid).
/// - **Safe areas**: cada pantalla se monta dentro de SafeArea; la zona baja
///   del juego reserva espacio para la gesture-nav bar.
/// - **Thumb zone**: durante el juego las acciones críticas (fichas + botón
///   principal) viven en el tercio central/inferior; arriba solo hay datos.
abstract final class AppLayout {
  /// Ancho máximo de contenido de "listas" (menú, ajustes, resultados).
  static const double maxContentWidth = 640;

  /// Lado máximo de la grilla de juego (cuadrado 1:1).
  static const double maxGameWidth = 480;

  /// Ancho máximo de diálogos/tarjetas de foco.
  static const double maxFocusWidth = 420;

  /// Pantallas de 600dp+ se tratan como tablet / plegable abierto / landscape.
  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600;

  /// Envuelve contenido de paneles: lo centra y le limita el ancho.
  ///
  /// En teléfonos el viewport es más angosto que [maxWidth] y termina
  /// limitando solo; nunca hace falta un caso "infinito".
  static Widget panel(
    BuildContext context, {
    required Widget child,
    double maxWidth = maxContentWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
