import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/layout/responsive.dart';
import '../router.dart';

/// Menú principal: entrada a los tres modos de juego.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openMode(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  void _comingSoon(BuildContext context, String mode) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$mode estará disponible próximamente')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: AppLayout.panel(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
            // Encabezado con la marca.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: scheme.primary,
                    child: Icon(Icons.palette_outlined, color: scheme.onPrimary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppConstants.appName,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Memorizá secuencias de colores',
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.settings),
                    tooltip: 'Accesibilidad',
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Opciones de juego.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: <Widget>[
                  _ModeCard(
                    icon: Icons.bolt,
                    title: 'Modo Clásico',
                    description: 'Secuencias que crecen en velocidad y longitud.',
                    enabled: true,
                    onTap: () => _openMode(context, AppRoutes.classic),
                  ),
                  const SizedBox(height: 12),
                  _ModeCard(
                    icon: Icons.event_available,
                    title: 'Desafío Diario',
                    description: 'Un reto único, igual para todos, cada 24 horas.',
                    enabled: false,
                    onTap: () => _comingSoon(context, 'El Desafío Diario'),
                  ),
                  const SizedBox(height: 12),
                  _ModeCard(
                    icon: Icons.spa,
                    title: 'Modo Zen',
                    description: 'Sin límites de tiempo ni penalizaciones.',
                    enabled: false,
                    onTap: () => _comingSoon(context, 'El Modo Zen'),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de un modo de juego del menú.
class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;

  /// Si el modo ya se puede jugar; si es false se muestra como "próximamente".
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Widget card = Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: scheme.surfaceContainerLow,
      child: InkWell(
        // Los modos bloqueados igual reaccionan al toque para avisar que
        // están "próximamente"; el estilo es el que varía con [enabled].
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 24,
                backgroundColor: scheme.primaryContainer,
                child: Icon(icon, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!enabled)
                _SoonChip(textTheme: textTheme, scheme: scheme)
              else
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );

    if (enabled) return card;
    return Opacity(opacity: 0.6, child: card);
  }
}

/// Etiqueta "próximamente" para modos todavía no disponibles.
class _SoonChip extends StatelessWidget {
  const _SoonChip({required this.textTheme, required this.scheme});

  final TextTheme textTheme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Próximamente',
        style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
