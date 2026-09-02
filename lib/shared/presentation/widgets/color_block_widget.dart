import 'package:flutter/material.dart';

import '../../domain/entities/color_block.dart';

/// Colores "de pantalla" para cada ficha (mapeo presentación → dominio).
///
/// Tono base vivo que funciona sobre superficies claras y oscuras. Si más
/// adelante se agregan texturas para daltonismo, este es el lugar donde se
/// combinan.
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
class ColorBlockWidget extends StatelessWidget {
  const ColorBlockWidget({
    super.key,
    required this.id,
    required this.onTap,
    this.highlighted = false,
  });

  final ColorId id;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final Color base = id.color;
    final Color display = highlighted
        ? (Color.lerp(base, Colors.white, 0.4) ?? base)
        : base;

    return Semantics(
      button: true,
      label: id.label,
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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }
}
