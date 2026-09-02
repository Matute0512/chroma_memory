import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Tema de Chroma Memory — Dark Cyber-Minimal.
///
/// La identidad es **oscura obligatoria**: no hay tema claro. La elevación se
/// hace con peldaños de valor + hairline (no sombras difusas); el color y el
/// glow viven en las fichas y en las acciones primarias.
abstract final class AppTheme {
  /// Único tema de la app.
  static ThemeData get dark => _build();

  static const ColorScheme _scheme = ColorScheme.dark(
    primary: AppPalette.brand,
    onPrimary: AppPalette.onAccent,
    primaryContainer: Color(0xFF241D52),
    onPrimaryContainer: Color(0xFFD8D2FF),
    secondary: AppPalette.cyan,
    onSecondary: Color(0xFF06131A),
    secondaryContainer: Color(0xFF0C3040),
    onSecondaryContainer: Color(0xFFBFF2FF),
    tertiary: AppPalette.magenta,
    onTertiary: Color(0xFF2A0A20),
    tertiaryContainer: Color(0xFF3E1637),
    onTertiaryContainer: Color(0xFFFFD3F0),
    error: AppPalette.coral,
    onError: Color(0xFF33000A),
    errorContainer: Color(0xFF57131F),
    onErrorContainer: Color(0xFFFFDADA),
    surface: AppPalette.surface,
    onSurface: AppPalette.textHigh,
    onSurfaceVariant: AppPalette.textMid,
    surfaceContainerLowest: Color(0xFF0A0F1C),
    surfaceContainerLow: Color(0xFF0E1729),
    surfaceContainer: Color(0xFF121C30),
    surfaceContainerHigh: Color(0xFF182338),
    surfaceContainerHighest: Color(0xFF1F2B44),
    outline: Color(0x2EFFFFFF),
    outlineVariant: Color(0x1AFFFFFF),
    shadow: Colors.black,
    scrim: AppPalette.scrim,
    brightness: Brightness.dark,
  );

  static ThemeData _build() {
    final TextTheme base = Typography.material2021().white
        .apply(fontFamily: AppPalette.fontUi)
        .copyWith(
          // Display — Unbounded
          displayLarge: _display(56),
          displayMedium: _display(40),
          displaySmall: _display(34),
          headlineLarge: _display(30),
          headlineMedium: _display(26),
          headlineSmall: _display(24),
          // UI — Manrope
          titleLarge: _ui(20, wght: 700),
          titleMedium: _ui(17, wght: 700),
          titleSmall: _ui(15, wght: 600),
          bodyLarge: _ui(16, height: 1.5),
          bodyMedium: _ui(15, height: 1.5),
          bodySmall: _ui(13, height: 1.45),
          labelLarge: _ui(14, wght: 700, spacing: 0.3),
          labelMedium: _ui(12, wght: 700, spacing: 0.5),
          labelSmall: _ui(11, wght: 700, spacing: 1.2),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: _scheme,
      textTheme: base,
      scaffoldBackgroundColor: AppPalette.voidBg,
      splashFactory: InkRipple.splashFactory,
      // Transición de pantallas: fade + deslizamiento sutil (no zoom genérico).
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _ChromaTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppPalette.voidBg,
        foregroundColor: AppPalette.textHigh,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: AppPalette.fontUi,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          color: AppPalette.textHigh,
        ),
      ),
    );
  }

  /// Estilo display (Unbounded). Peso fijo 600 vía eje wght.
  static TextStyle _display(double size) => TextStyle(
        fontFamily: AppPalette.fontDisplay,
        fontSize: size,
        height: 1.08,
        letterSpacing: -0.4,
        fontWeight: FontWeight.w600,
        color: AppPalette.textHigh,
        fontVariations: const <FontVariation>[FontVariation('wght', 600)],
      );

  /// Estilo de UI/cuerpo (Manrope). El peso se pide por eje `wght`.
  static TextStyle _ui(
    double size, {
    double wght = 400,
    double height = 1.4,
    double spacing = 0,
  }) {
    return TextStyle(
      fontFamily: AppPalette.fontUi,
      fontSize: size,
      height: height,
      letterSpacing: spacing,
      fontWeight: _weightFrom(wght),
      color: AppPalette.textHigh,
      fontVariations: <FontVariation>[FontVariation('wght', wght)],
    );
  }

  static FontWeight _weightFrom(double wght) => switch (wght.toInt()) {
        700 => FontWeight.w700,
        600 => FontWeight.w600,
        500 => FontWeight.w500,
        _ => FontWeight.w400,
      };
}

/// Transición por defecto de las rutas: fade + micro-slide vertical.
class _ChromaTransitionsBuilder extends PageTransitionsBuilder {
  const _ChromaTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final CurvedAnimation curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
