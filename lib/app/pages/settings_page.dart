import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/accessibility/accessibility_controller.dart';
import '../../core/accessibility/color_vision_mode.dart';
import '../../core/layout/responsive.dart';
import '../../shared/domain/entities/color_block.dart';
import '../../shared/presentation/widgets/color_block_widget.dart';

/// Ajustes de accesibilidad: modo daltónico con texturas en las fichas.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorVisionMode mode = ref.watch(accessibilityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accesibilidad')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            AppLayout.panel(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Modo daltónico',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Si tenés dificultad para distinguir colores (protanopía, '
                    'deuteranopía o tritanopía), activá una opción y cada ficha '
                    'mostrará una textura propia que no depende del color.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PreviewPanel(mode: mode),
                  const SizedBox(height: 24),
                  for (final ColorVisionMode option
                      in ColorVisionMode.values) ...[
                    _VisionTile(
                      mode: option,
                      selected: mode == option,
                      onTap: () => ref
                          .read(accessibilityProvider.notifier)
                          .setMode(option),
                    ),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Panel con las cuatro fichas tal como se verán en la partida.
class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.mode});

  final ColorVisionMode mode;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              for (final ColorId id in ColorId.values) ...[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ColorBlockWidget(
                      id: id,
                      onTap: null,
                      vision: mode,
                    ),
                  ),
                ),
                if (id != ColorId.values.last) const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            mode.usesPatterns
                ? 'Así se verán tus fichas: cada una tiene su patrón '
                    '(${mode.label.toLowerCase()}).'
                : 'Elegí tu condición arriba para activar las texturas.',
            style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Fila de opción de modo daltónico.
class _VisionTile extends StatelessWidget {
  const _VisionTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ColorVisionMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: selected ? scheme.secondaryContainer : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          selected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: selected ? scheme.onSecondaryContainer : scheme.outline,
        ),
        title: Text(mode.label),
        subtitle: Text(mode.description),
        selected: selected,
      ),
    );
  }
}
