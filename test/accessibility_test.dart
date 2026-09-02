// Tests de accesibilidad (daltonismo): modos, patrones por ficha y persistencia.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chroma_memory/core/accessibility/accessibility_controller.dart';
import 'package:chroma_memory/core/accessibility/accessibility_store.dart';
import 'package:chroma_memory/core/accessibility/color_vision_mode.dart';
import 'package:chroma_memory/shared/domain/entities/color_block.dart';
import 'package:chroma_memory/shared/presentation/widgets/accessibility_pattern_overlay.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('solo los modos daltónicos activan patrones', () {
    expect(ColorVisionMode.none.usesPatterns, isFalse);
    expect(ColorVisionMode.protanopia.usesPatterns, isTrue);
    expect(ColorVisionMode.deuteranopia.usesPatterns, isTrue);
    expect(ColorVisionMode.tritanopia.usesPatterns, isTrue);
  });

  test('cada ficha tiene un patrón distinto (no depende del color)', () {
    final Set<TilePattern> patterns = <TilePattern>{
      for (final ColorId id in ColorId.values) id.pattern,
    };
    expect(patterns.length, ColorId.values.length,
        reason: 'todas las fichas deben diferenciarse por su patrón');
  });

  test('persiste y carga el modo elegido', () async {
    final AccessibilityController controller =
        AccessibilityController(const AccessibilityStore());

    await controller.setMode(ColorVisionMode.deuteranopia);
    expect(controller.state, ColorVisionMode.deuteranopia);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('accessibility.vision_mode'), 'deuteranopia');

    // Un controlador nuevo (p. ej. próximo arranque) carga el valor guardado.
    final AccessibilityController reloaded =
        AccessibilityController(const AccessibilityStore());
    await Future<void>.delayed(Duration.zero); // deja terminar _load()
    expect(reloaded.state, ColorVisionMode.deuteranopia);
  });

  test('un nombre desconocido vuelve a "sin filtro"', () {
    expect(ColorVisionMode.fromName('nope'), ColorVisionMode.none);
    expect(ColorVisionMode.fromName(null), ColorVisionMode.none);
  });
}
