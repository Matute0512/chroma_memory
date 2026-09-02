import 'package:audioplayers/audioplayers.dart';

/// Sonidos cortos del juego (assets/sounds/).
///
/// Un solo reproductor en secuencia: los tonos son breves y no se solapan con
/// el ritmo de la fase "ver". Deshabilitable para tests o preferencia del
/// usuario. Tabla de disparo háptico/sonoro en IMPLEMENTACION.md.
class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  /// El reproductor se crea recién al primer [play] (lazy): acceder a
  /// [instance] en tests no debe tocar el canal del plugin.
  AudioPlayer? _player;

  /// Si está apagado, [play] no hace nada (tests, preferencia, sin audio).
  bool enabled = true;

  /// Reproduce un sfx por nombre de archivo (dentro de assets/sounds/).
  Future<void> play(String file) async {
    if (!enabled) return;
    try {
      final AudioPlayer player = _player ??= AudioPlayer();
      await player.stop();
      await player.play(AssetSource('sounds/$file'), volume: 0.9);
    } catch (_) {
      // Sin soporte de audio: silencio, no es un error para el jugador.
    }
  }
}
