import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/themes.dart';
import 'router.dart';

/// Widget raíz de ChromaMemory.
///
/// Arma el [MaterialApp] con el tema claro/oscuro (Material 3) y las rutas
/// nombradas definidas en [AppRoutes]. El [ProviderScope] se coloca en
/// main.dart, por encima de este widget.
class ChromaMemoryApp extends StatelessWidget {
  const ChromaMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      // Identidad dark neon: oscuro obligatorio (no hay tema claro).
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.table,
    );
  }
}
