import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/accessibility/color_vision_mode.dart';
import '../../../../core/constants/app_palette.dart';
import '../../../../core/layout/responsive.dart';
import '../../../../core/utils/audio_manager.dart';
import '../../../../core/utils/haptic_feedback.dart';
import '../../../../core/widgets/ambient_backdrop.dart';
import '../../../../core/widgets/chroma_button.dart';
import '../../../../core/widgets/glow_card.dart';
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

final ColorFilter _kNormalFilter = ColorFilter.mode(
  Colors.white,
  BlendMode.dst,
);
final ColorFilter _kDesaturatedFilter = ColorFilter.matrix(_kGrayscaleMatrix);

/// Pantalla de un modo de secuencias (Clásico / Desafío Diario / Zen).
///
/// Comparte el motor ([ClassicViewModel] con [SequenceRules]) y los
/// micro-feedback premium:
/// - acierto → "eco" de luz en la ficha + háptico light;
/// - ronda superada → háptico medium;
/// - error → shake + desaturación breve + háptico heavy (en Zen se continúa).
///
/// HUD inmersivo: sin AppBar; una barra superior fina (volver + modo + pausa)
/// y el tablero como protagonista. La pausa solo aplica durante el turno del
/// jugador (ver [ClassicViewModel.pause]).
class SequenceModePage extends ConsumerStatefulWidget {
  const SequenceModePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.provider,
  });

  /// Título del modo (overline del HUD y encabezado inicial).
  final String title;

  /// Descripción breve en la pantalla inicial.
  final String subtitle;

  /// Provider (StateNotifier) del modo concreto (ver core/di).
  final StateNotifierProvider<ClassicViewModel, ClassicState> provider;

  @override
  ConsumerState<SequenceModePage> createState() => _SequenceModePageState();
}

class _SequenceModePageState extends ConsumerState<SequenceModePage>
    with SingleTickerProviderStateMixin {
  Timer? _pulseTimer;
  Timer? _saturationTimer;
  ColorId? _pulseId;

  late final AnimationController _shakeController;
  bool _desaturated = false;

  /// Desafío Diario: si el reto de hoy ya se completó (bloquea "Comenzar").
  bool _completedToday = false;

  /// Espejo local de la pausa (para mostrar/ocultar el overlay al instante).
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    Future<void>.microtask(_prepare);
  }

  /// Deja la partida en ready, carga el récord y (Diario) chequea si ya se
  /// completó el reto de hoy.
  Future<void> _prepare() async {
    if (!mounted) return;
    final ClassicViewModel vm = ref.read(widget.provider.notifier);
    vm.resetToReady();
    await vm.loadBestScore();
    final bool done = await vm.isTodayCompleted();
    if (!mounted) return;
    if (done != _completedToday) setState(() => _completedToday = done);
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    _saturationTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _startGame() async {
    await ref.read(widget.provider.notifier).newGame();
  }

  void _pauseGame() {
    final ClassicState current = ref.read(widget.provider);
    if (current.phase != ClassicPhase.input) return;
    ref.read(widget.provider.notifier).pause();
    setState(() => _paused = true);
  }

  void _resumeGame() {
    ref.read(widget.provider.notifier).resume();
    if (mounted) setState(() => _paused = false);
  }

  Future<void> _restartFromPause() async {
    if (mounted) setState(() => _paused = false);
    await _startGame();
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
    final TapOutcome outcome = await ref
        .read(widget.provider.notifier)
        .onTile(id);
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
    final ClassicState finalState = ref.read(widget.provider);
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
    ref.read(widget.provider.notifier).resetToReady();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ClassicState state = ref.watch(widget.provider);
    final ColorVisionMode vision = ref.watch(accessibilityProvider);

    // Cuando termina la partida, ir a resultados (una sola vez por estado).
    ref.listen<ClassicState>(widget.provider, (
      ClassicState? prev,
      ClassicState next,
    ) {
      if (next.phase == ClassicPhase.gameOver &&
          prev?.phase != ClassicPhase.gameOver) {
        _openResults();
      }
    });

    // Tono del color en cada destello de la fase "ver" (sincronizado con luz).
    ref.listen<int?>(widget.provider.select((ClassicState s) => s.watchIndex), (
      int? prev,
      int? next,
    ) {
      if (next == null) return;
      final ClassicState current = ref.read(widget.provider);
      if (next < current.sequence.length) {
        final ColorId c = current.sequence.colors[next];
        unawaited(AudioManager.instance.play('${c.name}.wav'));
      }
    });

    final bool inGame = state.phase != ClassicPhase.ready;

    return PopScope(
      // Intercepta "volver" para detener la ronda antes de salir.
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _leaveToMenu();
      },
      child: Scaffold(
        body: AmbientBackdrop(
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _buildTopBar(context, state),
                    Expanded(
                      child: state.phase == ClassicPhase.ready
                          ? _buildReady(context, state)
                          : _buildGame(context, state, vision),
                    ),
                  ],
                ),
                // Overlay de pausa (solo durante una partida en curso).
                if (inGame && _paused)
                  _PauseOverlay(
                    state: state,
                    onResume: _resumeGame,
                    onRestart: _restartFromPause,
                    onMenu: _leaveToMenu,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Barra superior del HUD: volver + modo + pausa.
  Widget _buildTopBar(BuildContext context, ClassicState state) {
    final bool inGame = state.phase != ClassicPhase.ready;
    final bool canPause = state.phase == ClassicPhase.input;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 44,
            height: 44,
            child: _GlassBackButton(onPressed: _leaveToMenu),
          ),
          Expanded(
            child: Text(
              widget.title.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppPalette.textMid,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            width: 44,
            height: 44,
            // El "volver" tiene ancho simétrico para que el título quede centrado.
            child: inGame && canPause
                ? _GlassIcon(
                    icon: Icons.pause_rounded,
                    tooltip: 'Pausar',
                    onPressed: _pauseGame,
                  )
                : null,
          ),
        ],
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
          constraints: const BoxConstraints(maxWidth: AppLayout.maxFocusWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                _completedToday
                    ? Icons.check_circle_outline
                    : Icons.lightbulb_outline,
                size: 64,
                color: _completedToday ? AppPalette.mint : scheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
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
              if (_completedToday)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppPalette.mint.withValues(alpha: 0.10),
                    border: Border.all(
                      color: AppPalette.mint.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle,
                        size: 20,
                        color: AppPalette.mint,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '¡Reto completado hoy!',
                        style: textTheme.titleSmall?.copyWith(
                          color: AppPalette.mint,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ChromaButton(
                    icon: Icons.play_arrow,
                    label: 'Comenzar',
                    expanded: true,
                    onPressed: _startGame,
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
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ClassicScoreBar(state: state),
          const SizedBox(height: 10),
          Text(
            _statusMessage(state),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: roundCleared ? AppPalette.mint : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (BuildContext context, Widget? child) {
                  final double v = _shakeController.value;
                  final double dx = v > 0
                      ? math.sin(v * math.pi * 6) * (10 * (1 - v))
                      : 0;
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: ColorFiltered(
                      colorFilter: _desaturated
                          ? _kDesaturatedFilter
                          : _kNormalFilter,
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
                    enabled: !_paused && state.isInputEnabled,
                    onColorTap: _onColorTap,
                    pulseId: _pulseId,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
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

/// Botón "vidrio" del HUD: círculo discreto con hairline.
class _GlassIcon extends StatelessWidget {
  const _GlassIcon({required this.icon, required this.onPressed, this.tooltip});

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget child = Material(
      color: Colors.white.withValues(alpha: 0.04),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Icon(icon, size: 24, color: AppPalette.textHigh),
      ),
    );

    if (tooltip == null) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}

/// "Volver" de vidrio del HUD.
///
/// Usa un [BackButton] real (icono + tooltip localizado) para que la
/// accesibilidad y los tests de navegación (`pageBack`) lo reconozcan. El pop
/// lo intercepta el [PopScope] de la página (detiene la ronda antes de salir).
class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.04),
      shape: const CircleBorder(),
      child: BackButton(color: AppPalette.textHigh, onPressed: onPressed),
    );
  }
}

/// Overlay de pausa: barrera oscura + tarjeta de acciones.
class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({
    required this.state,
    required this.onResume,
    required this.onRestart,
    required this.onMenu,
  });

  final ClassicState state;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Stack(
      children: <Widget>[
        const ModalBarrier(dismissible: false, color: AppPalette.scrim),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.maxFocusWidth,
              ),
              child: GlowCard(
                glow: AppPalette.cyan,
                glowAlpha: 0.16,
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(
                      Icons.pause_circle_outline,
                      size: 52,
                      color: AppPalette.cyan,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'En pausa',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ronda ${state.round} · Puntaje ${state.score}',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textMid,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ChromaButton(
                      icon: Icons.play_arrow,
                      label: 'Reanudar',
                      expanded: true,
                      onPressed: onResume,
                    ),
                    const SizedBox(height: 10),
                    ChromaButton(
                      variant: ChromaButtonVariant.secondary,
                      icon: Icons.refresh,
                      label: 'Reiniciar',
                      expanded: true,
                      onPressed: onRestart,
                    ),
                    const SizedBox(height: 10),
                    ChromaButton(
                      variant: ChromaButtonVariant.secondary,
                      icon: Icons.home_outlined,
                      label: 'Salir al menú',
                      expanded: true,
                      onPressed: onMenu,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
