import 'package:flutter/material.dart';

import '../../../core/accessibility/color_vision_mode.dart';
import '../../domain/entities/color_block.dart';
import 'accessibility_pattern_overlay.dart';

/// Colores "de pantalla" para cada ficha (mapeo presentación → dominio).
///
/// Tono base vivo que funciona sobre superficies claras y oscuras.
extension ColorIdVisuals on ColorId {
  Color get color => switch (this) {
        ColorId.red => const Color(0xFFE53935),
        ColorId.green => const Color(0xFF43A047),
        ColorId.blue => const Color(0xFF1E88E5),
        ColorId.yellow => const Color(0xFFF9A825),
      };

  String get label => switch (this) {
        ColorId.red => 'Rojo',
        ColorId.green => 'Verde',
        ColorId.blue => 'Azul',
        ColorId.yellow => 'Amarillo',
      };
}

/// Ficha de color táctil del tablero.
///
/// [highlighted] enciende la ficha (destello de la fase "ver").
/// [vision] activa la textura de accesibilidad correspondiente al modo
/// daltónico elegido (ver core/accessibility).
class ColorBlockWidget extends StatelessWidget {
  const ColorBlockWidget({
    super.key,
    required this.id,
    required this.onTap,
    this.highlighted = false,
    this.vision = ColorVisionMode.none,
  });

  final ColorId id;
  final VoidCallback? onTap;
  final bool highlighted;
  final ColorVisionMode vision;

  @override
  Widget build(BuildContext context) {
    final Color base = id.color;
    final Color display =
        highlighted ? (Color.lerp(base, Colors.white, 0.4) ?? base) : base;
    final bool usesPatterns = vision.usesPatterns;

    final String semanticLabel = usesPatterns
        ? '${id.label}, con ${id.patternLabel}'
        : id.label;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: display,
          boxShadow: highlighted
              ? <BoxShadow>[
                  BoxShadow(
                    color: base.withValues(alpha: 0.55),
                    blurRadius: 26,
                    spreadRadius: 6,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (usesPatterns)
                TilePatternOverlay(
                  key: ValueKey<String>('pattern_${id.name}'),
                  id: id,
                  baseColor: display,
                ),
              Material(
                color: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  splashColor: Colors.white.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
