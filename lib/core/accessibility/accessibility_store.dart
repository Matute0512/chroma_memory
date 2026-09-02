import 'package:shared_preferences/shared_preferences.dart';

import 'color_vision_mode.dart';

/// Persistencia de la preferencia de accesibilidad (shared_preferences).
class AccessibilityStore {
  const AccessibilityStore();

  static const String _kVisionMode = 'accessibility.vision_mode';

  Future<ColorVisionMode> readVisionMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return ColorVisionMode.fromName(prefs.getString(_kVisionMode));
  }

  Future<void> writeVisionMode(ColorVisionMode mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kVisionMode, mode.name);
  }
}
