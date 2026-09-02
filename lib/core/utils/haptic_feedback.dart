import 'package:flutter/services.dart';

/// Feedback háptico de la app.
///
/// Usa el [HapticFeedback] nativo de Flutter (sin plugins de terceros).
/// Android y iOS lo soportan; ante un entorno sin plugin (ej. tests) se
/// ignora en silencio.
abstract final class AppHaptics {
  static Future<void> selection() => _run(HapticFeedback.selectionClick);

  static Future<void> light() => _run(HapticFeedback.lightImpact);

  static Future<void> medium() => _run(HapticFeedback.mediumImpact);

  static Future<void> heavy() => _run(HapticFeedback.heavyImpact);

  static Future<void> _run(Future<void> Function() call) async {
    try {
      await call();
    } on MissingPluginException {
      // Sin soporte de plataforma: no es un error para el jugador.
    }
  }
}
