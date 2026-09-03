import 'package:flutter/material.dart';

/// Lenguaje de movimiento de Chroma Memory (Punto 4).
///
/// Un único lugar donde viven las duraciones y curvas; ningún widget debe
/// hardcodear un `Duration` o una `Curve` aislados. La escala respeta la
/// percepción del brief: presión ~70 ms, destello ~120 ms, "pop-in" de
/// secuencia 200 ms, paneles/pantallas ~300 ms, shake 520 ms.
abstract final class AppMotion {
  // ---- Duraciones ----
  /// Presión de un control (escala de toque).
  static const Duration press = Duration(milliseconds: 70);

  /// Destello breve de una ficha (fase "ver" / eco de luz).
  static const Duration flash = Duration(milliseconds: 120);

  /// Encendido/pop-in de un elemento de la secuencia (escala + opacidad).
  static const Duration pop = Duration(milliseconds: 200);

  /// Eco de acierto / micro-feedback sobre una ficha.
  static const Duration echo = Duration(milliseconds: 200);

  /// Paneles, HUD y transiciones de foco.
  static const Duration panel = Duration(milliseconds: 300);

  /// Shake de error (se usa en las pantallas de juego).
  static const Duration shake = Duration(milliseconds: 520);

  // ---- Curvas ----
  /// Salida rápida y suave para micro-feedback (predeterminada).
  static const Curve easeOut = Curves.easeOut;

  /// Salida cúbica: la elegida para la mayoría de las transiciones.
  static const Curve easeOutCubic = Curves.easeOutCubic;

  /// Entrada cúbica (para reversas / errores).
  static const Curve easeInCubic = Curves.easeInCubic;

  /// "Pop-in": overshoot suave al encender una ficha o celebrar.
  static const Curve popIn = Curves.easeOutBack;

  /// Escala de "hundido" al presionar un control activo.
  static const double pressScale = 0.965;
}
