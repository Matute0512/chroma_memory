import 'package:flutter/material.dart';

import '../constants/app_palette.dart';
import '../motion/app_motion.dart';

/// Variantes de [ChromaButton].
///
/// - [primary]: gradiente CTA + glow (acción principal, reemplaza al botón lleno).
/// - [secondary]: plano elevado + hairline fuerte (acción neutral / "Menú").
/// - [danger]: coral + glow rojo (destructiva / salir de la partida).
enum ChromaButtonVariant { primary, secondary, danger }

/// Tamaños de [ChromaButton].
enum ChromaButtonSize { large, medium }

/// Botón táctil de Chroma Memory.
///
/// Feedback físico del brief: al presionar baja de escala ([AppMotion.press])
/// y enciende su halo; el glow siempre viene del color de la variante (o del
/// que se pase en [glowColor], p. ej. para acentuar cada modo de juego).
class ChromaButton extends StatefulWidget {
  const ChromaButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.variant = ChromaButtonVariant.primary,
    this.size = ChromaButtonSize.large,
    this.expanded = false,
    this.glowColor,
  }) : assert(
         label != null || icon != null,
         'ChromaButton necesita al menos un label o un icon.',
       );

  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final ChromaButtonVariant variant;
  final ChromaButtonSize size;

  /// Ocupa todo el ancho disponible (para CTAs de pantalla completa).
  final bool expanded;

  /// Halo override: permite teñir el botón del acento de un modo (oro, cian…).
  final Color? glowColor;

  @override
  State<ChromaButton> createState() => _ChromaButtonState();
}

class _ChromaButtonState extends State<ChromaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool enabled = widget.onPressed != null;
    final bool isLarge = widget.size == ChromaButtonSize.large;
    final double height = isLarge ? 56 : 48;
    const double radius = 16;

    final Color fg;
    final Color ripple;
    final Color? glowBase;
    final BoxDecoration decoration;

    switch (widget.variant) {
      case ChromaButtonVariant.primary:
        fg = AppPalette.onAccent;
        ripple = Colors.white.withValues(alpha: 0.32);
        glowBase = widget.glowColor ?? AppPalette.brand;
        decoration = BoxDecoration(
          gradient: AppPalette.ctaGradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: enabled
              ? AppPalette.glow(glowBase, blur: 24, alpha: 0.35)
              : null,
        );
      case ChromaButtonVariant.secondary:
        fg = AppPalette.textHigh;
        ripple = Colors.white.withValues(alpha: 0.16);
        glowBase = widget.glowColor;
        decoration = BoxDecoration(
          color: AppPalette.raised,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppPalette.lineStrong),
          boxShadow: (enabled && glowBase != null)
              ? AppPalette.glow(glowBase, blur: 18, alpha: 0.18)
              : null,
        );
      case ChromaButtonVariant.danger:
        fg = AppPalette.onAccent;
        ripple = Colors.white.withValues(alpha: 0.30);
        glowBase = AppPalette.coral;
        decoration = BoxDecoration(
          color: AppPalette.coral,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: enabled
              ? AppPalette.glow(AppPalette.coral, blur: 22, alpha: 0.30)
              : null,
        );
    }

    final TextStyle labelStyle =
        (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: fg,
        );

    final List<Widget> content = <Widget>[];
    if (widget.icon != null) {
      content.add(Icon(widget.icon, size: isLarge ? 22 : 20, color: fg));
    }
    if (widget.label != null) {
      if (widget.icon != null) content.add(const SizedBox(width: 8));
      content.add(Text(widget.label!, style: labelStyle));
    }

    final Widget face = SizedBox(
      height: height,
      width: widget.expanded ? double.infinity : null,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: decoration,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (bool value) {
              setState(() => _pressed = value);
            },
            borderRadius: BorderRadius.circular(radius),
            splashColor: ripple,
            highlightColor: Colors.white.withValues(alpha: 0.10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: content,
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: ExcludeSemantics(
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: AnimatedScale(
            scale: enabled && _pressed ? AppMotion.pressScale : 1,
            duration: AppMotion.press,
            curve: AppMotion.easeOutCubic,
            child: face,
          ),
        ),
      ),
    );
  }
}
