import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/audio_manager.dart';

/// Persistencia de la preferencia de sonido (shared_preferences).
class AudioPreferencesStore {
  const AudioPreferencesStore();

  static const String _kSoundEnabled = 'settings.sound_enabled';

  Future<bool> readEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSoundEnabled) ?? true;
  }

  Future<void> writeEnabled(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSoundEnabled, value);
  }
}

/// Controla el sonido de la app y lo refleja en [AudioManager.enabled].
class SoundController extends StateNotifier<bool> {
  SoundController(this._store) : super(true) {
    _load();
  }

  final AudioPreferencesStore _store;

  Future<void> _load() async {
    final bool stored = await _store.readEnabled();
    if (stored != state) state = stored;
    AudioManager.instance.enabled = state;
  }

  Future<void> setEnabled(bool value) async {
    if (value == state) return;
    state = value;
    AudioManager.instance.enabled = value;
    await _store.writeEnabled(value);
  }
}

/// Provider global de sonido. Los reproductores consultan este estado (a
/// través de [AudioManager.enabled]) antes de reproducir.
final StateNotifierProvider<SoundController, bool> soundEnabledProvider =
    StateNotifierProvider<SoundController, bool>(
  (ref) => SoundController(const AudioPreferencesStore()),
);
