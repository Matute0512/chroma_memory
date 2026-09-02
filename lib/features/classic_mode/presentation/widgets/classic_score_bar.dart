import 'package:flutter/material.dart';

import '../viewmodels/classic_viewmodel.dart';

/// Barra superior con el puntaje, la ronda y el récord de la partida.
class ClassicScoreBar extends StatelessWidget {
  const ClassicScoreBar({super.key, required this.state});

  final ClassicState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _ScoreItem(label: 'Puntaje', value: '${state.score}'),
        _ScoreItem(label: 'Ronda', value: '${state.round}'),
        _ScoreItem(label: 'Récord', value: '${state.bestScore}'),
      ],
    );
  }
}

class _ScoreItem extends StatelessWidget {
  const _ScoreItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
