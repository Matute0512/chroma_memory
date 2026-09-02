import 'package:flutter/material.dart';

import '../core/di/injection_container.dart';
import '../features/classic_mode/presentation/pages/sequence_mode_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/splash_page.dart';

/// Rutas con nombre de la aplicación.
///
/// Los modos de secuencias comparten [SequenceModePage] y difieren en título,
/// descripción y provider (reglas + persistencia de cada modo).
abstract final class AppRoutes {
  /// Splash de marca.
  static const String splash = '/splash';

  /// Menú principal.
  static const String home = '/';

  /// Modo Clásico.
  static const String classic = '/classic';

  /// Desafío Diario.
  static const String daily = '/daily';

  /// Modo Zen.
  static const String zen = '/zen';

  /// Ajustes (accesibilidad).
  static const String settings = '/settings';

  static final Map<String, WidgetBuilder> table = <String, WidgetBuilder>{
    splash: (_) => const SplashPage(),
    home: (_) => const HomePage(),
    classic: (_) => SequenceModePage(
          title: 'Modo Clásico',
          subtitle: 'Cada ronda suma un color más. Un error y terminás.',
          provider: classicViewModelProvider,
        ),
    daily: (_) => SequenceModePage(
          title: 'Desafío Diario',
          subtitle: 'El mismo reto para todos, cada 24 horas. Completalo hoy.',
          provider: dailyViewModelProvider,
        ),
    zen: (_) => SequenceModePage(
          title: 'Modo Zen',
          subtitle: 'Sin límites ni penalizaciones: aprendé a tu ritmo.',
          provider: zenViewModelProvider,
        ),
    settings: (_) => const SettingsPage(),
  };
}
