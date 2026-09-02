import 'package:flutter/material.dart';

/// Pantalla del Modo Clásico.
///
/// ⚠️ Página provisional para que la navegación del menú ya funcione.
/// La jugabilidad (secuencia, fases ver/input, grilla de colores, puntaje)
/// se implementa en la próxima iteración sobre esta misma página.
class ClassicGamePage extends StatelessWidget {
  const ClassicGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Modo Clásico')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 0,
              color: scheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.hourglass_empty, size: 40, color: scheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Preparando el tablero…',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'La jugabilidad del Modo Clásico se implementa en la '
                      'siguiente iteración.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver al menú'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
