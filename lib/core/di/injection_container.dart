import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/classic_mode/data/datasources/classic_local_datasource.dart';
import '../../features/classic_mode/data/repositories/classic_repository_impl.dart';
import '../../features/classic_mode/domain/repositories/i_classic_repository.dart';
import '../../features/classic_mode/domain/usecases/generate_sequence_usecase.dart';
import '../../features/classic_mode/domain/usecases/validate_user_input_usecase.dart';
import '../../features/classic_mode/presentation/viewmodels/classic_viewmodel.dart';

// Dependencias del Modo Clásico (manuales, sin codegen).

final Provider<ClassicLocalDataSource> classicLocalDataSourceProvider =
    Provider<ClassicLocalDataSource>(
  (ref) => const ClassicLocalDataSource(),
);

final Provider<IClassicRepository> classicRepositoryProvider =
    Provider<IClassicRepository>(
  (ref) => ClassicRepositoryImpl(ref.watch(classicLocalDataSourceProvider)),
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
