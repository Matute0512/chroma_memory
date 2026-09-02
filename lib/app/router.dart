import 'package:flutter/material.dart';

import '../features/classic_mode/presentation/pages/classic_game_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

/// Rutas con nombre de la aplicación.
///
/// Se usa una tabla estática de rutas porque hoy no hacen falta argumentos
/// complejos entre pantallas. Si la app crece (por ej. pasar el modo o el
/// nivel por ruta), conviene migrar a un router paramétrico.
abstract final class AppRoutes {
  /// Menú principal.
  static const String home = '/';

  /// Modo Clásico.
  static const String classic = '/classic';

  /// Ajustes (accesibilidad).
  static const String settings = '/settings';

  static final Map<String, WidgetBuilder> table = <String, WidgetBuilder>{
    home: (_) => const HomePage(),
    classic: (_) => const ClassicGamePage(),
    settings: (_) => const SettingsPage(),
  };
}
