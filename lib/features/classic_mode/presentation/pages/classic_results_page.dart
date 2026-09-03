import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_palette.dart';
import '../../../../core/widgets/ambient_backdrop.dart';
import '../../../../core/widgets/chroma_button.dart';
import '../../../../shared/presentation/widgets/confetti_burst.dart';
import '../viewmodels/classic_viewmodel.dart';

/// Pantalla de fin de partida (Clásico / Diario / Zen).
///
/// Retención y conversión: si fue récord o reto completado hay una lluvia de
/// partículas; "Reintentar" es el botón protagonista (gigante, abajo en la
/// zona del pulgar) y un hook pulsante de "2ª oportunidad" invita sin molestar.
///
/// Al tocar "Reintentar" hace `pop(true)`; "Menú principal" (o volver atrás)
/// desapila hasta el menú principal.
class ClassicResultsPage extends StatelessWidget {
  const ClassicResultsPage({super.key, required this.state});

  final ClassicState state;

  bool get _celebrate => state.isNewBest || state.completed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AmbientBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // La celebración vive detrás del encabezado (Icon area).
                    SizedBox(
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        fit: StackFit.expand,
                        children: <Widget>[
                          if (_celebrate)
                            const Positioned.fill(child: ConfettiBurst()),
                          _Trophy(state: state, scheme: scheme),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.completed
                          ? '¡Reto completado!'
                          : (state.isNewBest
                                ? '¡Nuevo récord!'
                                : 'Fin de la partida'),
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${state.score}',
                      textAlign: TextAlign.center,
                      style: textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: state.isNewBest
                            ? AppPalette.gold
                            : (state.completed
                                  ? AppPalette.mint
                                  : scheme.primary),
                        fontVariations: const <FontVariation>[
                          FontVariation('wght', 600),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.completed
                          ? 'Completaste el reto de hoy.'
                          : 'Llegaste a la ronda ${state.round}',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ChromaButton(
                      icon: Icons.replay,
                      label: 'Reintentar',
                      expanded: true,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                    if (!state.completed) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: _SecondChanceButton(
                          onPressed: () {
                            final ScaffoldMessengerState messenger =
                                ScaffoldMessenger.of(context);
                            messenger
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  width: 300,
                                  content: Text(
                                    'La 2ª oportunidad llega pronto.',
                                  ),
                                ),
                              );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(
                        context,
                      ).popUntil((Route<void> route) => route.isFirst),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Menú principal'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ícono de trofeo según el desenlace de la partida.
class _Trophy extends StatelessWidget {
  const _Trophy({required this.state, required this.scheme});

  final ClassicState state;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final Color color = state.completed
        ? AppPalette.mint
        : (state.isNewBest ? AppPalette.gold : scheme.outline);

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.10),
          border: Border.all(color: color.withValues(alpha: 0.45)),
          boxShadow: state.isNewBest || state.completed
              ? AppPalette.glow(color, blur: 30, alpha: 0.45)
              : null,
        ),
        child: Icon(Icons.emoji_events, size: 42, color: color),
      ),
    );
  }
}

/// Hook de "2ª oportunidad": corazón de neón que pulsa suavemente.
class _SecondChanceButton extends StatefulWidget {
  const _SecondChanceButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_SecondChanceButton> createState() => _SecondChanceButtonState();
}

class _SecondChanceButtonState extends State<_SecondChanceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    const Color glow = AppPalette.magenta;

    return Semantics(
      button: true,
      label: 'Segunda oportunidad',
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (BuildContext context, Widget? child) {
          // 0.5..1 sinusoidal → el halo respira sin llegar a molestar.
          final double wave = 0.5 + 0.5 * math.sin(_pulse.value * math.pi * 2);
          final double alpha = 0.16 + 0.26 * wave;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: glow.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: glow.withValues(alpha: 0.5)),
                  boxShadow: AppPalette.glow(
                    glow,
                    blur: 22,
                    alpha: alpha.clamp(0, 0.9),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.favorite, size: 18, color: glow),
                    const SizedBox(width: 8),
                    Text(
                      '2ª oportunidad',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppPalette.textHigh,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
