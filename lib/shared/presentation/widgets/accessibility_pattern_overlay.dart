import 'package:flutter/material.dart';

import '../../domain/entities/color_block.dart';

/// Patrones geométricos que diferencian las fichas sin depender del color.
///
/// Los cuatro patrones (diagonal, horizontal, puntos y cuadrícula) son
/// distinguibles entre sí por geometría pura, de modo que funcionan para
/// cualquier deficiencia de visión del color (protanopía, deuteranopía,
/// tritanopía).
enum TilePattern { stripesDiagonal, stripesHorizontal, dots, checkerboard }

/// Patrón asignado a cada ficha.
extension ColorIdPattern on ColorId {
  TilePattern get pattern => switch (this) {
        ColorId.red => TilePattern.stripesDiagonal,
        ColorId.green => TilePattern.stripesHorizontal,
        ColorId.blue => TilePattern.dots,
        ColorId.yellow => TilePattern.checkerboard,
      };

  /// Nombre legible del patrón (también se usa en Semantics).
  String get patternLabel => switch (pattern) {
        TilePattern.stripesDiagonal => 'rayas diagonales',
        TilePattern.stripesHorizontal => 'rayas horizontales',
        TilePattern.dots => 'puntos',
        TilePattern.checkerboard => 'cuadrícula',
      };
}

/// Capa de textura sobre una ficha, dibujada con el patrón de su color.
class TilePatternOverlay extends StatelessWidget {
  const TilePatternOverlay({
    super.key,
    required this.id,
    required this.baseColor,
  });

  final ColorId id;

  /// Color sobre el que se pinta (se usa para elegir un trazo con contraste).
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _PatternPainter(
          pattern: id.pattern,
          stroke: _strokeFor(id, baseColor),
        ),
        size: Size.infinite,
      ),
    );
  }

  /// Trazo blanco para tonos oscuros y oscuro para tonos claros (amarillo).
  Color _strokeFor(ColorId colorId, Color base) =>
      base.computeLuminance() > 0.45 ? Colors.black54 : Colors.white70;
}

class _PatternPainter extends CustomPainter {
  _PatternPainter({required this.pattern, required this.stroke});

  final TilePattern pattern;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final double m = size.shortestSide;
    if (m <= 0) return;

    final Paint paint = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = (m * 0.05).clamp(2.0, 7.0)
      ..strokeCap = StrokeCap.round;

    switch (pattern) {
      case TilePattern.stripesDiagonal:
        _drawDiagonalStripes(canvas, size, paint);
      case TilePattern.stripesHorizontal:
        _drawHorizontalStripes(canvas, size, paint);
      case TilePattern.dots:
        _drawDots(canvas, size);
      case TilePattern.checkerboard:
        _drawCheckerboard(canvas, size);
    }
  }

  void _drawDiagonalStripes(Canvas canvas, Size size, Paint paint) {
    final double spacing = size.shortestSide / 3.2;
    final double height = size.height;
    for (double x = -height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + height, height),
        paint,
      );
    }
  }

  void _drawHorizontalStripes(Canvas canvas, Size size, Paint paint) {
    final double spacing = size.height / 4;
    for (double y = spacing / 2; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawDots(Canvas canvas, Size size) {
    final double m = size.shortestSide;
    final double spacing = m / 3;
    final double radius = (m * 0.05).clamp(1.6, 5.0);

    final Paint fill = Paint()
      ..color = stroke
      ..style = PaintingStyle.fill;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, fill);
      }
    }
  }

  void _drawCheckerboard(Canvas canvas, Size size) {
    final double cell = size.shortestSide / 4;

    final Paint fill = Paint()
      ..color = stroke
      ..style = PaintingStyle.fill;

    int row = 0;
    for (double y = 0; y < size.height; y += cell) {
      int col = row.isEven ? 0 : 1;
      for (double x = 0; x < size.width; x += cell) {
        if (col.isOdd) {
          canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), fill);
        }
        col++;
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) =>
      oldDelegate.pattern != pattern || oldDelegate.stroke != stroke;
}
