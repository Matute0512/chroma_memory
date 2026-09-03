import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_palette.dart';
import '../../core/di/injection_container.dart';
import '../../core/layout/responsive.dart';
import '../../core/widgets/ambient_backdrop.dart';
import '../../core/widgets/chroma_button.dart';
import '../../core/widgets/glow_card.dart';

/// Récord de un modo, para la tabla.
class _LeaderEntry {
  const _LeaderEntry({
    required this.title,
    required this.icon,
    required this.accent,
    required this.best,
  });

  final String title;
  final IconData icon;
  final Color accent;

  /// Mejor puntaje histórico del modo (0 = todavía no jugó).
  final int best;
}

/// Récords de los tres modos, ordenados de mayor a menor.
final FutureProvider<List<_LeaderEntry>> _leaderboardProvider =
    FutureProvider<List<_LeaderEntry>>((ref) async {
      final Future<int> classic = ref
          .watch(classicRepositoryProvider)
          .getBestScore();
      final Future<int> zen = ref.watch(zenRepositoryProvider).getBestScore();
      final Future<int> daily = ref
          .watch(dailyRepositoryProvider)
          .getBestScore();
      final List<int> scores = await Future.wait<int>(<Future<int>>[
        classic,
        zen,
        daily,
      ]);

      final List<_LeaderEntry> entries = <_LeaderEntry>[
        _LeaderEntry(
          title: 'Modo Clásico',
          icon: Icons.bolt,
          accent: AppPalette.brand,
          best: scores[0],
        ),
        _LeaderEntry(
          title: 'Modo Zen',
          icon: Icons.spa,
          accent: AppPalette.cyan,
          best: scores[1],
        ),
        _LeaderEntry(
          title: 'Desafío Diario',
          icon: Icons.event_available,
          accent: AppPalette.amber,
          best: scores[2],
        ),
      ]..sort((a, b) => b.best.compareTo(a.best));
      return entries;
    });

/// Colores de las medallas (1º oro, 2º plata, 3º bronce).
const List<Color> _kMedals = <Color>[
  AppPalette.gold,
  Color(0xFFB9C4DE),
  Color(0xFFE0986B),
];

/// Tabla de clasificación local: tu mejor marca en cada modo.
///
/// Es un ranking personal (los récords viven en el dispositivo, en
/// shared_preferences por modo). Cuando exista un backend, esta pantalla es el
/// único punto a reemplazar.
class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Clasificación')),
      body: AmbientBackdrop(
        child: SafeArea(
          child: ref
              .watch(_leaderboardProvider)
              .when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object e, StackTrace s) =>
                    const Center(child: Text('No se pudo cargar la tabla.')),
                data: (List<_LeaderEntry> entries) {
                  final bool hasScores = entries.any(
                    (_LeaderEntry e) => e.best > 0,
                  );
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    children: <Widget>[
                      AppLayout.panel(
                        context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Tus récords por modo',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tu mejor marca en cada modo de Chroma Memory.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (hasScores)
                              for (int i = 0; i < entries.length; i++) ...[
                                _LeaderRow(entry: entries[i], rank: i),
                                if (i < entries.length - 1)
                                  const SizedBox(height: 12),
                              ]
                            else
                              const _EmptyBoard(),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
        ),
      ),
    );
  }
}

/// Fila de la tabla: medalla, modo y su mejor puntaje.
class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.entry, required this.rank});

  final _LeaderEntry entry;

  /// Posición (0 = líder). Se usa para el color de la medalla.
  final int rank;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool hasScore = entry.best > 0;
    final int medalIndex = rank < 0
        ? 0
        : (rank >= _kMedals.length ? _kMedals.length - 1 : rank);
    final Color medal = hasScore ? _kMedals[medalIndex] : scheme.outline;

    return GlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 20,
      glow: hasScore && rank == 0 ? entry.accent : null,
      glowAlpha: 0.12,
      child: Row(
        children: <Widget>[
          // Losa del modo con su acento.
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: entry.accent,
              borderRadius: BorderRadius.circular(15),
              boxShadow: AppPalette.glow(entry.accent, blur: 16, alpha: 0.35),
            ),
            child: Icon(entry.icon, color: AppPalette.onAccent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    // Medalla del puesto.
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: medal.withValues(alpha: 0.16),
                        border: Border.all(color: medal.withValues(alpha: 0.6)),
                      ),
                      child: Center(
                        child: rank == 0 && hasScore
                            ? Icon(Icons.emoji_events, size: 11, color: medal)
                            : Text(
                                '${rank + 1}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: medal,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasScore
                          ? (rank == 0 ? 'Líder' : 'Puesto ${rank + 1}')
                          : 'Sin jugar',
                      style: textTheme.labelSmall?.copyWith(color: medal),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            hasScore ? '${entry.best}' : '—',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasScore ? entry.accent : scheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado vacío: todavía no hay ningún récord guardado.
class _EmptyBoard extends StatelessWidget {
  const _EmptyBoard();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: <Widget>[
          Icon(Icons.emoji_events_outlined, size: 44, color: scheme.outline),
          const SizedBox(height: 12),
          Text(
            'Todavía no hay récords…',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Jugá una partida en cualquier modo y tu mejor marca '
            'aparece acá.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ChromaButton(
            variant: ChromaButtonVariant.secondary,
            icon: Icons.home_outlined,
            label: 'Volver al menú',
            expanded: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
