import '../../../../shared/domain/entities/color_block.dart';

/// Una secuencia de colores a memorizar y reproducir.
class ClassicSequence {
  const ClassicSequence(this.colors);

  final List<ColorId> colors;

  int get length => colors.length;
}
