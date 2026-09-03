import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../constants/app_palette.dart';

/// Fondo ambiental de Chroma Memory.
///
/// Lleva a la app los radiales del `design/style_guide.html` (marca violeta en
/// la parte alta, cian al costado, magenta abajo) que hoy solo existen en la
/// guía: la profundidad deja de ser un gris plano y el neón empieza a respirar
/// detrás del contenido.
///
/// Se monta como primera capa de cada pantalla:
/// `AmbientBackdrop(child: SafeArea(...))`. El fondo se dibuja por debajo de
/// las zonas de sistema (status/gesture bar) para verse como wallpaper.
class AmbientBackdrop extends StatelessWidget {
  const AmbientBackdrop({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Base: el negro orgánico de la identidad (nunca gris puro).
        const ColoredBox(color: AppPalette.voidBg),
        const IgnorePointer(child: CustomPaint(painter: _AmbientPainter())),
        ?child,
      ],
    );
  }
}

/// Pintor de los tres halos radiales.
///
/// El color de cada halo baja a 0 a los bordes; ninguno llega a opacidad
/// plena en ninguna parte, de modo que el fondo nunca compite con las fichas.
class _AmbientPainter extends CustomPainter {
  const _AmbientPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // Marca: cielo violeta tenue arriba (el "ambientTop" de los headers).
    _glow(
      canvas,
      size,
      center: Offset(size.width * 0.5, -size.height * 0.15),
      radius: size.width * 1.05,
      color: AppPalette.brand,
      alpha: 0.15,
    );
    // Sistema: chispa cian hacia el costado alto.
    _glow(
      canvas,
      size,
      center: Offset(size.width * 1.02, size.height * 0.02),
      radius: size.width * 0.80,
      color: AppPalette.cyan,
      alpha: 0.07,
    );
    // Acento: halo magenta tenue en la esquina baja opuesta.
    _glow(
      canvas,
      size,
      center: Offset(-size.width * 0.05, size.height * 1.05),
      radius: size.width * 0.90,
      color: AppPalette.magenta,
      alpha: 0.06,
    );
  }

  void _glow(
    Canvas canvas,
    Size size, {
    required Offset center,
    required double radius,
    required Color color,
    required double alpha,
  }) {
    final Paint paint = Paint()
      ..shader = ui.Gradient.radial(center, radius, <Color>[
        color.withValues(alpha: alpha),
        color.withValues(alpha: 0),
      ]);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) => false;
}
