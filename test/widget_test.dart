// Pruebas del shell de la app (menú, navegación), del MVP del Modo Clásico
// y de los ajustes de accesibilidad.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chroma_memory/app/app.dart';
import 'package:chroma_memory/core/utils/audio_manager.dart';

/// Espera una transición de ruta con pumps discretos.
///
/// La Home anima su título de neón en bucle (respeta TickerMode), por eso no se
/// puede "asentar" con pumpAndSettle: aquí se avanzan frames fijos.
Future<void> settle(
  WidgetTester tester, [
  Duration duration = const Duration(milliseconds: 400),
]) async {
  await tester.pump(); // arranca la transición
  await tester.pump(duration); // la completa
  await tester.pump(); // frame final (builds asíncronos)
}

void main() {
  setUp(() {
    // El Modo Clásico guarda el récord en shared_preferences.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // Sin audio en tests (evita el canal de plugin de audioplayers).
    AudioManager.instance.enabled = false;
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChromaMemoryApp()));
    // Splash de marca (1 s) → reemplaza a la Home.
    await tester.pump(const Duration(milliseconds: 1001));
    await settle(tester);
  }

  testWidgets('el menú principal muestra las tres opciones de modo', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Chroma Memory'), findsOneWidget);
    expect(find.text('Modo Clásico'), findsOneWidget);
    expect(find.text('Desafío Diario'), findsOneWidget);
    expect(find.text('Modo Zen'), findsOneWidget);
  });

  testWidgets('Modo Clásico navega a su pantalla inicial', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Modo Clásico'));
    await settle(tester);

    expect(find.text('Comenzar'), findsOneWidget);
    expect(find.text('Tu récord: 0'), findsOneWidget);
  });

  testWidgets('Desafío Diario y Modo Zen abren sus pantallas', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    // Desafío Diario.
    await tester.tap(find.text('Desafío Diario'));
    await settle(tester);
    expect(find.text('Desafío Diario'), findsWidgets); // AppBar + encabezado
    expect(find.text('Comenzar'), findsOneWidget);

    // Volver al menú y abrir Zen.
    await tester.pageBack();
    await settle(tester);
    await tester.tap(find.text('Modo Zen'));
    await settle(tester);
    expect(find.text('Modo Zen'), findsWidgets);
    expect(find.text('Comenzar'), findsOneWidget);
  });

  testWidgets('Comenzar arranca la partida y pasa a la fase de input', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Modo Clásico'));
    await settle(tester);

    await tester.tap(find.text('Comenzar'));
    await tester.pump(); // dispara newGame (lee récord + fase watching).

    // Al principio se está mostrando la secuencia.
    expect(find.text('Prestá atención…'), findsOneWidget);

    // Avanza el reloj de prueba para que terminen los destellos (ronda 1 =
    // 2 colores). La velocidad inicial por paso es ~700 ms.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Tu turno: repetí la secuencia'), findsOneWidget);
  });

  testWidgets(
    'elegir un modo daltónico activa las texturas en la vista previa',
    (WidgetTester tester) async {
      // Viewport alto para que todas las opciones queden visibles sin scroll.
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await settle(tester);

      expect(find.text('Modo daltónico'), findsOneWidget);

      // Sin modo elegido no hay texturas.
      expect(find.byKey(const ValueKey<String>('pattern_red')), findsNothing);

      await tester.tap(find.text('Deuteranopía'));
      await tester.pump();

      // La vista previa ahora pinta el patrón de la ficha roja.
      expect(find.byKey(const ValueKey<String>('pattern_red')), findsOneWidget);
      expect(find.textContaining('cada una tiene su patrón'), findsOneWidget);
    },
  );

  testWidgets('Clasificación abre su tabla (vacía sin récords)', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Clasificación'));
    await settle(tester);
    await tester.pump(); // resuelve el récord local (vacío en tests)

    expect(find.text('Clasificación'), findsWidgets); // AppBar de la tabla
    expect(find.text('Todavía no hay récords…'), findsOneWidget);
  });
}
