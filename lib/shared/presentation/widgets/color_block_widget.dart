import 'package:flutter/material.dart';

import '../../../core/accessibility/color_vision_mode.dart';
import '../../../core/constants/app_palette.dart';
import '../../domain/entities/color_block.dart';
import 'accessibility_pattern_overlay.dart';

/// Colores "de pantalla" para cada ficha (mapeo presentación → dominio).
///
/// Tono base + glow: el destello usa el glow del propio color, no un blanqueo
/// genérico (ver app_palette.dart).
extension ColorIdVisuals on ColorId {
  Color get color => switch (this) {
        ColorId.red => AppPalette.tileEmber,
        ColorId.green => AppPalette.tileMint,
        ColorId.blue => AppPalette.tileAzure,
        ColorId.yellow => AppPalette.tileAmber,
      };

  /// Halo del color de la ficha (se usa en el destello).
  Color get glow => switch (this) {
        ColorId.red => AppPalette.glowEmber,
        ColorId.green => AppPalette.glowMint,
        ColorId.blue => AppPalette.glowAzure,
        ColorId.yellow => AppPalette.glowAmber,
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
/// [highlighted] enciende la ficha (destello de la fase "ver") con un halo del
/// color de la propia ficha.
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
        highlighted ? (Color.lerp(base, Colors.white, 0.25) ?? base) : base;
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
          border: Border.all(color: AppPalette.hairline),
          boxShadow: highlighted
              ? <BoxShadow>[
                  BoxShadow(
                    color: id.glow.withValues(alpha: 0.55),
                    blurRadius: 34,
                    spreadRadius: 4,
                  ),
                ]
              : <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
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
