import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/haptic_feedback.dart';
import '../../../../shared/domain/entities/color_block.dart';
import '../viewmodels/classic_viewmodel.dart';
import '../widgets/classic_grid.dart';
import '../widgets/classic_score_bar.dart';
import '../widgets/classic_sequence_display.dart';
import 'classic_results_page.dart';

/// Pantalla del Modo Clásico (Simon-like).
///
/// Orquesta la UI con el [ClassicViewModel]: arranca la partida, reacciona a
/// los toques con hápticos y navega a resultados cuando termina.
class ClassicGamePage extends ConsumerStatefulWidget {
  const ClassicGamePage({super.key});

  @override
  ConsumerState<ClassicGamePage> createState() => _ClassicGamePageState();
}

class _ClassicGamePageState extends ConsumerState<ClassicGamePage> {
  @override
  void initState() {
    super.initState();
    // Carga el récord para mostrarlo en la pantalla inicial.
    Future<void>.microtask(() {
      if (mounted) {
        ref.read(classicViewModelProvider.notifier).loadBestScore();
      }
    });
  }

  Future<void> _startGame() async {
    await ref.read(classicViewModelProvider.notifier).newGame();
  }

  /// Sale al menú deteniendo la partida (si estaba a mitad de ronda).
  void _leaveToMenu() {
    ref.read(classicViewModelProvider.notifier).resetToReady();
    Navigator.of(context).pop();
  }

  Future<void> _onColorTap(ColorId id) async {
    final TapOutcome outcome =
        await ref.read(classicViewModelProvider.notifier).onTile(id);
    switch (outcome) {
      case TapOutcome.correct:
      case TapOutcome.roundCleared:
        await AppHaptics.light();
      case TapOutcome.wrong:
        await AppHaptics.heavy();
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

  @override
  Widget build(BuildContext context) {
    final ClassicState state = ref.watch(classicViewModelProvider);

    // Cuando termina la partida, ir a resultados (una sola vez por estado).
    ref.listen<ClassicState>(classicViewModelProvider, (ClassicState? prev, ClassicState next) {
      if (next.phase == ClassicPhase.gameOver &&
          prev?.phase != ClassicPhase.gameOver) {
        _openResults();
      }
    });

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
              : _buildGame(context, state),
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
          constraints: const BoxConstraints(maxWidth: 420),
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
  Widget _buildGame(BuildContext context, ClassicState state) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

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
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: ClassicGrid(state: state, onColorTap: _onColorTap),
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
