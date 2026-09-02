import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/color_block_widget.dart';
import '../viewmodels/classic_viewmodel.dart';

/// Muestra el avance del jugador dentro de la secuencia de la ronda actual
/// como una fila de puntos: coloreados los ya reproducidos, grises los que
/// faltan.
class ClassicSequenceDisplay extends StatelessWidget {
  const ClassicSequenceDisplay({super.key, required this.state});

  final ClassicState state;

  @override
  Widget build(BuildContext context) {
    if (state.sequence.length == 0) return const SizedBox.shrink();

    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < state.sequence.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < state.userProgress
                  ? state.sequence.colors[i].color
                  : scheme.surfaceContainerHighest,
              border: i >= state.userProgress
                  ? Border.all(color: scheme.outlineVariant)
                  : null,
            ),
          ),
        ],
      ],
    );
  }
}
