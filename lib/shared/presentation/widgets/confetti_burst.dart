import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_palette.dart';

/// Lluvia de partículas de celebración (nuevo récord / reto completado).
///
/// Es una animación **finita** (~1.6 s): explota una vez y se retira. Las
/// partículas usan una semilla fija, así el trazo es reproducible entre
/// builds y en tests. Se monta como overlay (IgnorePointer) sobre el área a
/// festejar.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key});

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    // Semilla fija para que la lluvia sea idéntica cada vez (y en tests).
    _particles = _Particle.burst(math.Random(20260903), _kCelebrationColors);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
  }

  static const List<Color> _kCelebrationColors = <Color>[
    AppPalette.gold,
    AppPalette.cyan,
    AppPalette.magenta,
    AppPalette.brandBright,
    AppPalette.mint,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          // Cuando termina ya no hay nada que pintar (las partículas salieron
          // del área): soltar el painter ahorra trabajo por frame.
          if (_controller.isCompleted) return const SizedBox.shrink();
          return CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(
              progress: _controller.value,
              particles: _particles,
            ),
          );
        },
      ),
    );
  }
}

/// Una partícula: posición inicial, forma, color, tamaño y dinámica.
class _Particle {
  const _Particle({
    required this.x,
    required this.phase,
    required this.size,
    required this.color,
    required this.fall,
    required this.sway,
    required this.frequency,
    required this.spin,
    required this.circle,
  });

  /// Posición horizontal inicial (0..1 del ancho).
  final double x;

  /// Retraso individual (0..1 de la animación) antes de caer.
  final double phase;

  final double size;
  final Color color;

  /// Velocidad de caída (en alturas por unidad de progreso).
  final double fall;

  /// Amplitud del vaivén horizontal (en fracción del ancho).
  final double sway;

  final double frequency;
  final double spin;

  /// true = punto, false = confeti rectangular.
  final bool circle;

  static List<_Particle> burst(math.Random rng, List<Color> palette) {
    const int count = 90;
    return List<_Particle>.generate(count, (int i) {
      final bool circle = rng.nextBool();
      return _Particle(
        x: rng.nextDouble(),
        phase: rng.nextDouble() * 0.28,
        size: 5 + rng.nextDouble() * 5,
        color: palette[rng.nextInt(palette.length)],
        fall: 0.75 + rng.nextDouble() * 0.55,
        sway: 0.02 + rng.nextDouble() * 0.05,
        frequency: 1.5 + rng.nextDouble() * 3,
        spin: (rng.nextDouble() - 0.5) * 22,
        circle: circle,
      );
    });
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.particles});

  final double progress;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    for (final _Particle p in particles) {
      // El progreso de esta partícula arranca tras su retraso.
      final double local = (progress - p.phase) / (1 - p.phase);
      if (local <= 0) continue;

      // Entra suave, sale fundiéndose en el último tramo.
      final double alpha = _ease(local);
      if (alpha <= 0) continue;

      // Caída + vaivén horizontal.
      final double fall = p.fall;
      final double y = size.height * (local * 1.25 * fall - 0.08);
      final double xOffset = math.sin(local * math.pi * 2 * p.frequency);
      final double x =
          size.width * (p.x + xOffset * p.sway) + xOffset * p.sway * 30;

      final Paint paint = Paint()..color = p.color.withValues(alpha: alpha);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(local * p.spin);

      if (p.circle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.6,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  /// Fundido de entrada y salida de cada partícula.
  double _ease(double local) {
    if (local > 0.78) return (1 - local) / 0.22;
    if (local < 0.10) return local / 0.10;
    return 1;
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
