import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/entities/color_block.dart';
import '../../domain/entities/classic_sequence.dart';
import '../../domain/repositories/i_classic_repository.dart';
import '../../domain/usecases/generate_sequence_usecase.dart';
import '../../domain/usecases/validate_user_input_usecase.dart';

/// Fase en la que está la partida.
enum ClassicPhase {
  /// Pantalla inicial, esperando que el jugador arranque.
  ready,

  /// Mostrando la secuencia a memorizar (input deshabilitado).
  watching,

  /// Turno del jugador: debe reproducir la secuencia.
  input,

  /// Acaba de completar la ronda correctamente (pausa breve).
  roundCleared,

  /// Falló y terminó la partida.
  gameOver,
}

/// Resultado de tocar una ficha, para que la UI decida el feedback.
enum TapOutcome { none, correct, roundCleared, wrong }

/// Estado inmutable del Modo Clásico.
class ClassicState {
  const ClassicState({
    required this.phase,
    required this.sequence,
    required this.userProgress,
    required this.round,
    required this.score,
    required this.bestScore,
    required this.isNewBest,
    this.watchIndex,
  });

  factory ClassicState.initial({int bestScore = 0}) => ClassicState(
        phase: ClassicPhase.ready,
        sequence: const ClassicSequence(<ColorId>[]),
        userProgress: 0,
        round: 1,
        score: 0,
        bestScore: bestScore,
        isNewBest: false,
      );

  final ClassicPhase phase;

  /// Secuencia de la ronda actual (vacía en ready).
  final ClassicSequence sequence;

  /// Cuántos colores correctos reprodujo el jugador en la ronda actual.
  final int userProgress;

  /// Ronda actual (1-based). La longitud de la secuencia es round + 1.
  final int round;

  /// Puntaje de la partida: un punto por color correcto.
  final int score;

  /// Mejor puntaje histórico.
  final int bestScore;

  /// Si esta partida rompió el récord.
  final bool isNewBest;

  /// Índice del color que está destellando durante [ClassicPhase.watching].
  final int? watchIndex;

  bool get isInputEnabled => phase == ClassicPhase.input;

  ClassicState copyWith({
    ClassicPhase? phase,
    ClassicSequence? sequence,
    int? userProgress,
    int? round,
    int? score,
    int? bestScore,
    bool? isNewBest,
    int? watchIndex,
  }) {
    return ClassicState(
      phase: phase ?? this.phase,
      sequence: sequence ?? this.sequence,
      userProgress: userProgress ?? this.userProgress,
      round: round ?? this.round,
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      isNewBest: isNewBest ?? this.isNewBest,
      watchIndex: watchIndex ?? this.watchIndex,
    );
  }
}

/// Controla la lógica de una partida del Modo Clásico (Simon-like).
///
/// Flujo: [newGame] → fase watching (destellan los colores) → input (el
/// jugador reproduce). Cada ronda suma un color a la secuencia. Un error
/// termina la partida ([ClassicPhase.gameOver]).
class ClassicViewModel extends StateNotifier<ClassicState> {
  ClassicViewModel({
    required IClassicRepository repository,
    required GenerateSequenceUseCase generateSequence,
    required ValidateUserInputUseCase validateInput,
  })  : _repository = repository,
        _generateSequence = generateSequence,
        _validateInput = validateInput,
        super(ClassicState.initial());

  final IClassicRepository _repository;
  final GenerateSequenceUseCase _generateSequence;
  final ValidateUserInputUseCase _validateInput;

  /// Token para invalidar tareas en vuelo (destellos, pausas) al reiniciar.
  int _token = 0;

  bool _busy = false;

  /// Si esta partida superó el mejor puntaje (para mostrarlo al final).
  bool _earnedNewBest = false;

  /// Velocidad del destello: baja con cada ronda (cada vez más rápido).
  Duration get _stepDelay =>
      Duration(milliseconds: math.max(240, 700 - (state.round - 1) * 40));

  static const Duration _gap = Duration(milliseconds: 180);
  static const Duration _roundPause = Duration(milliseconds: 900);

  /// Carga el mejor puntaje guardado (para mostrarlo en la pantalla inicial).
  Future<void> loadBestScore() async {
    final int best = await _repository.getBestScore();
    if (state.bestScore != best) {
      state = state.copyWith(bestScore: best);
    }
  }

  /// Arranca una partida nueva.
  Future<void> newGame() async {
    _token++;
    _busy = false;
    _earnedNewBest = false;
    final int token = _token;

    final int best = await _repository.getBestScore();
    if (token != _token) return;

    state = ClassicState.initial(bestScore: best);
    await _playRound(token);
  }

  /// El jugador tocó una ficha. Devuelve cómo seguir para dar feedback.
  Future<TapOutcome> onTile(ColorId tapped) async {
    if (_busy || !state.isInputEnabled) return TapOutcome.none;
    final int token = _token;

    final ClassicSequence sequence = state.sequence;
    final bool isCorrect =
        _validateInput(
              sequence: sequence.colors,
              index: state.userProgress,
              tapped: tapped,
            ) ==
            UserInputValidation.correct;

    if (!isCorrect) {
      // Termina la partida. El récord se actualiza en vivo apenas se supera,
      // así que basta con recordar si en algún momento se superó.
      _token++;
      state = state.copyWith(
        phase: ClassicPhase.gameOver,
        isNewBest: _earnedNewBest,
      );
      return TapOutcome.wrong;
    }

    // Acierto: +1 punto y avanza dentro de la ronda.
    final int newScore = state.score + 1;
    if (newScore > state.bestScore) {
      _earnedNewBest = true;
      unawaited(_repository.saveBestScore(newScore));
      state = state.copyWith(score: newScore, bestScore: newScore);
    } else {
      state = state.copyWith(score: newScore);
    }

    if (state.userProgress < sequence.length - 1) {
      state = state.copyWith(userProgress: state.userProgress + 1);
      return TapOutcome.correct;
    }

    // Ronda completa: pausa breve y pasa a la siguiente.
    _busy = true;
    state = state.copyWith(
      phase: ClassicPhase.roundCleared,
      userProgress: sequence.length,
    );
    await Future<void>.delayed(_roundPause);
    if (token != _token) return TapOutcome.roundCleared;

    state = state.copyWith(round: state.round + 1, userProgress: 0);
    await _playRound(token);
    return TapOutcome.roundCleared;
  }

  /// Vuelve al estado inicial y cancela destellos/pausas en vuelo.
  /// Se llama cuando el jugador abandona la pantalla a mitad de partida.
  void resetToReady() {
    _token++;
    _busy = false;
    state = ClassicState.initial(bestScore: state.bestScore);
  }

  /// Destella la secuencia de la ronda actual y habilita el input.
  Future<void> _playRound(int token) async {
    _busy = true;
    final ClassicSequence sequence =
        _generateSequence(length: state.round + 1);
    state = state.copyWith(
      phase: ClassicPhase.watching,
      sequence: sequence,
      userProgress: 0,
      watchIndex: null,
    );

    for (int i = 0; i < sequence.length; i++) {
      if (token != _token) return;
      state = state.copyWith(watchIndex: i);
      await Future<void>.delayed(_stepDelay);
      if (token != _token) return;
      state = state.copyWith(watchIndex: null);
      if (i < sequence.length - 1) {
        await Future<void>.delayed(_gap);
      }
    }

    if (token != _token) return;
    state = state.copyWith(phase: ClassicPhase.input, watchIndex: null);
    _busy = false;
  }
}
