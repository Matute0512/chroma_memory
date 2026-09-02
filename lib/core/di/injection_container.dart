import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/classic_mode/data/datasources/classic_local_datasource.dart';
import '../../features/classic_mode/data/repositories/classic_repository_impl.dart';
import '../../features/classic_mode/domain/repositories/i_classic_repository.dart';
import '../../features/classic_mode/domain/usecases/generate_sequence_usecase.dart';
import '../../features/classic_mode/domain/usecases/validate_user_input_usecase.dart';
import '../../features/classic_mode/presentation/viewmodels/classic_viewmodel.dart';

// Dependencias de los modos de secuencias (manuales, sin codegen).

final Provider<ClassicLocalDataSource> classicLocalDataSourceProvider =
    Provider<ClassicLocalDataSource>(
  (ref) => const ClassicLocalDataSource(),
);

final Provider<IClassicRepository> classicRepositoryProvider =
    Provider<IClassicRepository>(
  (ref) => ClassicRepositoryImpl(ref.watch(classicLocalDataSourceProvider)),
);

final Provider<IClassicRepository> zenRepositoryProvider =
    Provider<IClassicRepository>(
  // Récord propio del Modo Zen.
  (ref) => const ClassicRepositoryImpl(
    ClassicLocalDataSource(prefix: 'zen_mode'),
  ),
);

final Provider<IClassicRepository> dailyRepositoryProvider =
    Provider<IClassicRepository>(
  // Récord propio del Desafío Diario.
  (ref) => const ClassicRepositoryImpl(
    ClassicLocalDataSource(prefix: 'daily_mode'),
  ),
);

final Provider<GenerateSequenceUseCase> generateSequenceUseCaseProvider =
    Provider<GenerateSequenceUseCase>(
  (ref) => const GenerateSequenceUseCase(),
);

final Provider<ValidateUserInputUseCase> validateUserInputUseCaseProvider =
    Provider<ValidateUserInputUseCase>(
  (ref) => const ValidateUserInputUseCase(),
);

final StateNotifierProvider<ClassicViewModel, ClassicState>
    classicViewModelProvider =
    StateNotifierProvider<ClassicViewModel, ClassicState>(
  (ref) => ClassicViewModel(
    repository: ref.watch(classicRepositoryProvider),
    generateSequence: ref.watch(generateSequenceUseCaseProvider),
    validateInput: ref.watch(validateUserInputUseCaseProvider),
  ),
);

final StateNotifierProvider<ClassicViewModel, ClassicState>
    zenViewModelProvider =
    StateNotifierProvider<ClassicViewModel, ClassicState>(
  (ref) => ClassicViewModel(
    repository: ref.watch(zenRepositoryProvider),
    generateSequence: ref.watch(generateSequenceUseCaseProvider),
    validateInput: ref.watch(validateUserInputUseCaseProvider),
    // Zen: sin penalización; ante un error se vuelve a mostrar la secuencia.
    rules: const SequenceRules(
      startLength: 2,
      endOnMistake: false,
      reviewOnMistake: true,
    ),
  ),
);

final StateNotifierProvider<ClassicViewModel, ClassicState>
    dailyViewModelProvider =
    StateNotifierProvider<ClassicViewModel, ClassicState>(
  (ref) => ClassicViewModel(
    repository: ref.watch(dailyRepositoryProvider),
    generateSequence: ref.watch(generateSequenceUseCaseProvider),
    validateInput: ref.watch(validateUserInputUseCaseProvider),
    // Diario: secuencia única determinística por fecha, sin crecimiento.
    rules: SequenceRules(
      startLength: 6,
      growRounds: false,
      fixedSeed: _dailySeed(DateTime.now()),
    ),
  ),
);

/// Semilla del día (misma secuencia para todos, cambia cada 24 h).
int _dailySeed(DateTime date) =>
    date.year * 10000 + date.month * 100 + date.day;
