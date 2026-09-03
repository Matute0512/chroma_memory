import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/accessibility/accessibility_controller.dart';
import '../../core/accessibility/color_vision_mode.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_palette.dart';
import '../../core/layout/responsive.dart';
import '../../core/widgets/ambient_backdrop.dart';
import '../../core/widgets/chroma_button.dart';
import '../../core/widgets/glow_card.dart';
import '../router.dart';

/// Menú principal de Chroma Memory.
///
/// "Gran formato": un título de neón que juega con la luz, tres accesos de
/// juego como tarjetas grandes (cada modo con su acento) y un dock inferior en
/// la zona del pulgar con Ajustes (refleja si el modo daltónico está activo) y
/// la Tabla de clasificación.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _openMode(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.settings);
  }

  void _openLeaderboard(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.leaderboard);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorVisionMode vision = ref.watch(accessibilityProvider);

    return Scaffold(
      body: AmbientBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // Zona superior: título de neón + opciones de juego (scrollable).
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppLayout.maxContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _BrandMark(),
                          const SizedBox(height: 18),
                          const _NeonTitle(text: AppConstants.appName),
                          const SizedBox(height: 8),
                          Text(
                            'Memorizá secuencias de colores',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppPalette.textMid),
                          ),
                          // Estado del modo daltónico, a la vista (si está on).
                          if (vision.usesPatterns) ...[
                            const SizedBox(height: 14),
                            _VisionPill(
                              mode: vision,
                              onTap: () => _openSettings(context),
                            ),
                          ],
                          const SizedBox(height: 26),
                          _ModeStageCard(
                            icon: Icons.bolt,
                            accent: AppPalette.brand,
                            title: 'Modo Clásico',
                            description:
                                'Secuencias que crecen en velocidad y longitud.',
                            onTap: () => _openMode(context, AppRoutes.classic),
                          ),
                          const SizedBox(height: 14),
                          _ModeStageCard(
                            icon: Icons.event_available,
                            accent: AppPalette.amber,
                            title: 'Desafío Diario',
                            description:
                                'Un reto único, igual para todos, cada 24 horas.',
                            onTap: () => _openMode(context, AppRoutes.daily),
                          ),
                          const SizedBox(height: 14),
                          _ModeStageCard(
                            icon: Icons.spa,
                            accent: AppPalette.cyan,
                            title: 'Modo Zen',
                            description:
                                'Sin límites de tiempo ni penalizaciones.',
                            onTap: () => _openMode(context, AppRoutes.zen),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Dock inferior: zona caliente del pulgar.
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppLayout.maxContentWidth,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ChromaButton(
                          variant: ChromaButtonVariant.secondary,
                          size: ChromaButtonSize.medium,
                          icon: vision.usesPatterns
                              ? Icons.accessibility_new
                              : Icons.settings_outlined,
                          label: 'Ajustes',
                          glowColor: vision.usesPatterns
                              ? AppPalette.cyan
                              : null,
                          onPressed: () => _openSettings(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChromaButton(
                          variant: ChromaButtonVariant.secondary,
                          size: ChromaButtonSize.medium,
                          icon: Icons.leaderboard_outlined,
                          label: 'Clasificación',
                          onPressed: () => _openLeaderboard(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sello de marca superior.
class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: AppPalette.ctaGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppPalette.glow(AppPalette.brand, blur: 22, alpha: 0.55),
        ),
        child: const Icon(
          Icons.palette_outlined,
          color: AppPalette.onAccent,
          size: 24,
        ),
      ),
    );
  }
}

/// Título de marca con luces de neón en movimiento.
///
/// Un destello (que deriva de cian a magenta a lo largo del ciclo) cruza el
/// texto sobre el color de marca. La animación respeta el sistema: se pausa
/// sola cuando la Home queda detrás de otra ruta (`TickerMode`) y se detiene
/// si el usuario activó "reducir movimiento".
class _NeonTitle extends StatefulWidget {
  const _NeonTitle({required this.text});

  final String text;

  @override
  State<_NeonTitle> createState() => _NeonTitleState();
}

class _NeonTitleState extends State<_NeonTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _sweep.stop();
      _sweep.value = 0;
    } else if (!_sweep.isAnimating) {
      _sweep.repeat();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduced = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      header: true,
      child: AnimatedBuilder(
        animation: _sweep,
        builder: (BuildContext context, Widget? child) {
          final double t = reduced ? 0 : _sweep.value;
          // El centro del destello viaja de un borde al otro del texto; cuando
          // sale, el texto queda de color de marca puro (seamless al repetir).
          final double center = -1.3 + 2.6 * t;
          final Color band =
              Color.lerp(AppPalette.cyan, AppPalette.magenta, t) ??
              AppPalette.cyan;

          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment(center - 1, -0.2),
                end: Alignment(center + 1, 0.5),
                colors: <Color>[AppPalette.brand, band, AppPalette.brand],
                stops: const <double>[0, 0.5, 1],
              ).createShader(bounds);
            },
            child: child,
          );
        },
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppPalette.fontDisplay,
            fontSize: 34,
            height: 1.12,
            letterSpacing: -0.4,
            fontWeight: FontWeight.w600,
            fontVariations: const <FontVariation>[FontVariation('wght', 600)],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de modo de juego "gran formato".
///
/// Superficie con hairline + un halo tenue del acento del modo, icono grande en
/// una losa del color del acento y flecha a la derecha. Es el botón de entrada
/// a cada modo.
class _ModeStageCard extends StatelessWidget {
  const _ModeStageCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GlowCard(
      onTap: onTap,
      radius: 20,
      glow: accent,
      glowAlpha: 0.14,
      glowBlur: 26,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppPalette.glow(accent, blur: 18, alpha: 0.40),
            ),
            child: Icon(icon, color: AppPalette.onAccent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppPalette.textMid,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.45)),
            ),
            child: Icon(Icons.chevron_right, size: 20, color: accent),
          ),
        ],
      ),
    );
  }
}

/// Píldora que muestra el modo daltónico activo y abre Ajustes al tocarla.
class _VisionPill extends StatelessWidget {
  const _VisionPill({required this.mode, required this.onTap});

  final ColorVisionMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.center,
      child: Material(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.accessibility_new,
                  size: 16,
                  color: scheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Daltónico: ${mode.label}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
