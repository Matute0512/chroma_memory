import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/accessibility/color_vision_mode.dart';
import '../../../../core/constants/app_palette.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../../../core/utils/haptic_feedback.dart';
import '../../../../shared/domain/entities/color_block.dart';
import '../viewmodels/classic_viewmodel.dart';
import '../widgets/classic_grid.dart';
import '../widgets/classic_score_bar.dart';
import '../widgets/classic_sequence_display.dart';
import 'classic_results_page.dart';

/// Matriz de desaturación (escala de grises). Se usa el instante del error.
const List<double> _kGrayscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0,
];

final ColorFilter _kNormalFilter =
    ColorFilter.mode(Colors.white, BlendMode.dst);
final ColorFilter _kDesaturatedFilter = ColorFilter.matrix(_kGrayscaleMatrix);

/// Pantalla del Modo Clásico (Simon-like).
///
/// Orquesta la UI con el [ClassicViewModel] y los micro-feedback premium:
/// - acierto → "eco" de luz en la ficha + háptico light;
/// - ronda superada → háptico medium;
/// - error → shake del tablero + desaturación momentánea + háptico heavy.
class ClassicGamePage extends ConsumerStatefulWidget {
  const ClassicGamePage({super.key});

  @override
  ConsumerState<ClassicGamePage> createState() => _ClassicGamePageState();
}

class _ClassicGamePageState extends ConsumerState<ClassicGamePage>
    with SingleTickerProviderStateMixin {
  Timer? _pulseTimer;
  Timer? _saturationTimer;
  ColorId? _pulseId;

  late final AnimationController _shakeController;
  bool _desaturated = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    // Carga el récord para mostrarlo en la pantalla inicial.
    Future<void>.microtask(() {
      if (mounted) {
        ref.read(classicViewModelProvider.notifier).loadBestScore();
      }
    });
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    _saturationTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _startGame() async {
    await ref.read(classicViewModelProvider.notifier).newGame();
  }

  /// "Eco" de luz sobre la ficha que se acertó.
  void _echoCorrect(ColorId id) {
    _pulseTimer?.cancel();
    setState(() => _pulseId = id);
    _pulseTimer = Timer(const Duration(milliseconds: 160), () {
      if (mounted) setState(() => _pulseId = null);
    });
  }

  /// Shake + desaturación breve al fallar.
  void _playError() {
    _shakeController.forward(from: 0);
    _saturationTimer?.cancel();
    setState(() => _desaturated = true);
    _saturationTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _desaturated = false);
    });
  }

  Future<void> _onColorTap(ColorId id) async {
    final TapOutcome outcome =
        await ref.read(classicViewModelProvider.notifier).onTile(id);
    switch (outcome) {
      case TapOutcome.correct:
        _echoCorrect(id);
        await AppHaptics.light();
        await AudioManager.instance.play('tap_ok.wav');
      case TapOutcome.roundCleared:
        _echoCorrect(id);
        await AppHaptics.medium();
        await AudioManager.instance.play('round_ok.wav');
      case TapOutcome.wrong:
        _playError();
        await AppHaptics.heavy();
        await AudioManager.instance.play('error.wav');
      case TapOutcome.none:
        break;
    }
  }

  Future<void> _openResults() async {
    final ClassicState finalState = ref.read(classicViewModelProvider);
    final bool? retry = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ClassicResultsPage(state: finalState),
      ),
    );
    if (!mounted) return;
    if (retry == true) {
      await _startGame();
    } else {
      Navigator.of(context).popUntil((Route<void> route) => route.isFirst);
    }
  }

  /// Salta al menú deteniendo la partida (si estaba a mitad de ronda).
  void _leaveToMenu() {
    ref.read(classicViewModelProvider.notifier).resetToReady();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ClassicState state = ref.watch(classicViewModelProvider);
    final ColorVisionMode vision = ref.watch(accessibilityProvider);

    // Cuando termina la partida, ir a resultados (una sola vez por estado).
    ref.listen<ClassicState>(classicViewModelProvider, (ClassicState? prev, ClassicState next) {
      if (next.phase == ClassicPhase.gameOver &&
          prev?.phase != ClassicPhase.gameOver) {
        _openResults();
      }
    });

    // Tono del color en cada destello de la fase "ver" (sincronizado con la luz).
    ref.listen<int?>(
      classicViewModelProvider.select((ClassicState s) => s.watchIndex),
      (int? prev, int? next) {
        if (next == null) return;
        final ClassicState current = ref.read(classicViewModelProvider);
        if (next < current.sequence.length) {
          final ColorId c = current.sequence.colors[next];
          unawaited(AudioManager.instance.play('${c.name}.wav'));
        }
      },
    );

    return PopScope(
      // Intercepta "volver" para detener la ronda antes de salir.
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _leaveToMenu();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Modo Clásico')),
        body: SafeArea(
          child: state.phase == ClassicPhase.ready
              ? _buildReady(context, state)
              : _buildGame(context, state, vision),
        ),
      ),
    );
  }

  /// Pantalla inicial con el botón para arrancar.
  Widget _buildReady(BuildContext context, ClassicState state) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppLayout.maxFocusWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.lightbulb_outline, size: 64, color: scheme.primary),
              const SizedBox(height: 16),
              Text(
                'Memorizá la secuencia y repetila',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cada ronda suma un color más. Un error y terminás.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu récord: ${state.bestScore}',
                style: textTheme.bodySmall?.copyWith(color: scheme.primary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Comenzar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tablero de juego en plena partida.
  Widget _buildGame(
    BuildContext context,
    ClassicState state,
    ColorVisionMode vision,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool roundCleared = state.phase == ClassicPhase.roundCleared;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ClassicScoreBar(state: state),
          const SizedBox(height: 12),
          Text(
            _statusMessage(state),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: roundCleared
                  ? AppPalette.mint
                  : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (BuildContext context, Widget? child) {
                  final double v = _shakeController.value;
                  final double dx =
                      v > 0 ? math.sin(v * math.pi * 6) * (10 * (1 - v)) : 0;
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: ColorFiltered(
                      colorFilter:
                          _desaturated ? _kDesaturatedFilter : _kNormalFilter,
                      child: child,
                    ),
                  );
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppLayout.maxGameWidth,
                  ),
                  child: ClassicGrid(
                    state: state,
                    vision: vision,
                    onColorTap: _onColorTap,
                    pulseId: _pulseId,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: ClassicSequenceDisplay(state: state)),
        ],
      ),
    );
  }

  String _statusMessage(ClassicState state) => switch (state.phase) {
        ClassicPhase.ready => '',
        ClassicPhase.watching => 'Prestá atención…',
        ClassicPhase.input => 'Tu turno: repetí la secuencia',
        ClassicPhase.roundCleared => '¡Ronda ${state.round} superada!',
        ClassicPhase.gameOver => '',
      };
}
