import 'package:flutter/material.dart';

import '../../../../core/accessibility/color_vision_mode.dart';
import '../../../../shared/domain/entities/color_block.dart';
import '../../../../shared/presentation/widgets/color_block_widget.dart';
import '../viewmodels/classic_viewmodel.dart';

/// Grilla 2×2 de fichas de color.
///
/// [vision] define si se pintan las texturas de accesibilidad.
/// [pulseId] es la ficha que hace un "eco" de luz al acertar (feedback breve).
/// [enabled] permite bloquear el toque además de la fase (p. ej. al pausar);
/// si es null se usa el estado de la fase ([ClassicState.isInputEnabled]).
class ClassicGrid extends StatelessWidget {
  const ClassicGrid({
    super.key,
    required this.state,
    required this.vision,
    required this.onColorTap,
    this.enabled,
    this.pulseId,
  });

  final ClassicState state;
  final ColorVisionMode vision;
  final ValueChanged<ColorId> onColorTap;
  final bool? enabled;
  final ColorId? pulseId;

  @override
  Widget build(BuildContext context) {
    final bool canTap = enabled ?? state.isInputEnabled;
    final List<ColorId> order = ColorId.values;
    final bool watching = state.phase == ClassicPhase.watching;

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
                    onTap: canTap ? () => onColorTap(id) : null,
                    vision: vision,
                    highlighted:
                        (watching &&
                            state.watchIndex != null &&
                            state.sequence.colors[state.watchIndex!] == id) ||
                        pulseId == id,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
