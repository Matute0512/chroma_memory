import 'package:flutter/material.dart';

import '../../../../shared/domain/entities/color_block.dart';
import '../../../../shared/presentation/widgets/color_block_widget.dart';
import '../viewmodels/classic_viewmodel.dart';

/// Grilla 2×2 de fichas de color.
///
/// [enabled] deshabilita el toque (durante la fase "ver", pausas, etc.).
class ClassicGrid extends StatelessWidget {
  const ClassicGrid({
    super.key,
    required this.state,
    required this.onColorTap,
  });

  final ClassicState state;
  final ValueChanged<ColorId> onColorTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = state.isInputEnabled;
    final List<ColorId> order = ColorId.values;

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double gap = constraints.maxWidth * 0.06;
          final double cell = (constraints.maxWidth - gap) / 2;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: <Widget>[
              for (final ColorId id in order)
                SizedBox(
                  width: cell,
                  height: cell,
                  child: ColorBlockWidget(
                    key: ValueKey<String>('tile_${id.name}'),
                    id: id,
                    onTap: enabled ? () => onColorTap(id) : null,
                    highlighted: state.phase == ClassicPhase.watching &&
                        state.watchIndex != null &&
                        state.sequence.colors[state.watchIndex!] == id,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
