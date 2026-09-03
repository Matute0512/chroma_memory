import 'package:flutter/material.dart';

import '../constants/app_palette.dart';

/// Tarjeta de superficie de Chroma Memory.
///
/// Sustituye al `Card` genérico + `InkWell` que cada pantalla repetía a mano:
/// un plano con peldaño de valor (color de superficie), hairline de 1 px y,
/// opcional, un halo del color del elemento (glow). Las superficies NO usan
/// sombra difusa (regla del style guide): la elevación es peldaño + hairline.
///
/// Si se le pasa [onTap] (o [onLongPress]) se comporta como botón: ripple
/// suave recortado a la forma, sin cambiar de escala (para eso está
/// [ChromaButton]).
class GlowCard extends StatelessWidget {
  const GlowCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.color,
    this.glow,
    this.glowBlur = 28,
    this.glowAlpha = 0.20,
    this.radius = 18,
    this.padding = const EdgeInsets.all(20),
    this.border,
  });

  final Widget child;

  /// Si no es null, la tarjeta es táctil (ripple al tocar).
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Peldaño de superficie. Por defecto el mismo plano que ya usa el menú.
  final Color? color;

  /// Halo de color (el glow viene del color del elemento). Si es null, plano.
  final Color? glow;
  final double glowBlur;
  final double glowAlpha;

  final double radius;
  final EdgeInsetsGeometry padding;

  /// Borde; por defecto el hairline de la identidad.
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color bg = color ?? scheme.surfaceContainerLow;
    final Color edge = border ?? AppPalette.hairline;
    final BorderRadius radius = BorderRadius.circular(this.radius);

    final bool interactive = onTap != null || onLongPress != null;

    final BoxDecoration decoration = BoxDecoration(
      color: bg,
      borderRadius: radius,
      border: Border.all(color: edge),
      boxShadow: glow != null
          ? AppPalette.glow(glow!, blur: glowBlur, alpha: glowAlpha)
          : null,
    );

    if (!interactive) {
      return DecoratedBox(
        decoration: decoration,
        child: Padding(padding: padding, child: child),
      );
    }

    // Ripple recortado un peldaño adentro para no tapar el hairline.
    return DecoratedBox(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(this.radius - 1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            highlightColor: Colors.white.withValues(alpha: 0.06),
            splashColor: Colors.white.withValues(alpha: 0.08),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
