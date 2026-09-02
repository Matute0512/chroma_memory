import 'dart:math';

import '../../../../shared/domain/entities/color_block.dart';
import '../entities/classic_sequence.dart';

/// Genera una secuencia aleatoria de [length] colores.
///
/// Regla de jugabilidad: nunca dos colores iguales consecutivos (así cada
/// destello de la fase "ver" se distingue con claridad).
class GenerateSequenceUseCase {
  const GenerateSequenceUseCase();

  ClassicSequence call({required int length, Random? random}) {
    final Random rng = random ?? Random();
    final List<ColorId> colors = <ColorId>[];
    final List<ColorId> palette = ColorId.values;

    while (colors.length < length) {
      final ColorId next = palette[rng.nextInt(palette.length)];
      if (colors.isNotEmpty && colors.last == next) continue;
      colors.add(next);
    }
    return ClassicSequence(colors);
  }
}
