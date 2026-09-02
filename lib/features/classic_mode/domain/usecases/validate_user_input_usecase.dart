import '../../../../shared/domain/entities/color_block.dart';

/// Resultado de comparar el color tocado contra la posición esperada.
enum UserInputValidation { correct, wrong }

/// Valida si el color tocado por el usuario coincide con la posición
/// [index] de la [sequence].
class ValidateUserInputUseCase {
  const ValidateUserInputUseCase();

  UserInputValidation call({
    required List<ColorId> sequence,
    required int index,
    required ColorId tapped,
  }) {
    if (index < 0 || index >= sequence.length) {
      return UserInputValidation.wrong;
    }
    return sequence[index] == tapped
        ? UserInputValidation.correct
        : UserInputValidation.wrong;
  }
}
