import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'accessibility_store.dart';
import 'color_vision_mode.dart';

/// Controla la preferencia de accesibilidad visual.
class AccessibilityController extends StateNotifier<ColorVisionMode> {
  AccessibilityController(this._store) : super(ColorVisionMode.none) {
    _load();
  }

  final AccessibilityStore _store;

  Future<void> _load() async {
    final ColorVisionMode stored = await _store.readVisionMode();
    if (stored != state) state = stored;
  }

  Future<void> setMode(ColorVisionMode mode) async {
    if (mode == state) return;
    state = mode;
    await _store.writeVisionMode(mode);
  }
}

/// Provider global de accesibilidad. Cualquier ficha que renderice colores
/// debería escuchar este estado para aplicar sus texturas.
final StateNotifierProvider<AccessibilityController, ColorVisionMode>
    accessibilityProvider =
    StateNotifierProvider<AccessibilityController, ColorVisionMode>(
  (ref) => AccessibilityController(const AccessibilityStore()),
);
