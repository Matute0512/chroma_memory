import 'package:flutter/material.dart';

import '../../../../core/constants/app_palette.dart';
import '../viewmodels/classic_viewmodel.dart';

/// Pantalla de fin de partida del Modo Clásico.
///
/// Al tocar "Jugar de nuevo" hace `pop(true)`; "Menú" (o volver atrás)
/// desapila hasta el menú principal.
class ClassicResultsPage extends StatelessWidget {
  const ClassicResultsPage({super.key, required this.state});

  final ClassicState state;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.emoji_events,
                    size: 72,
                    color: state.completed
                        ? AppPalette.mint
                        : (state.isNewBest
                            ? AppPalette.gold
                            : scheme.outline),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.completed
                        ? '¡Reto completado!'
                        : (state.isNewBest
                            ? '¡Nuevo récord!'
                            : 'Fin de la partida'),
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.score}',
                    style: textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.completed
                        ? 'Completaste el reto de hoy.'
                        : 'Llegaste a la ronda ${state.round}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.replay),
                    label: const Text('Jugar de nuevo'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .popUntil((Route<void> route) => route.isFirst),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Menú principal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
