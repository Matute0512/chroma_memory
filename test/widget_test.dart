// Pruebas del shell de la app (menú, navegación), del MVP del Modo Clásico
// y de los ajustes de accesibilidad.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chroma_memory/app/app.dart';

void main() {
  setUp(() {
    // El Modo Clásico guarda el récord en shared_preferences.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChromaMemoryApp()));
  }

  testWidgets('el menú principal muestra las tres opciones de modo',
      (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.text('Chroma Memory'), findsOneWidget);
    expect(find.text('Modo Clásico'), findsOneWidget);
    expect(find.text('Desafío Diario'), findsOneWidget);
    expect(find.text('Modo Zen'), findsOneWidget);
  });

  testWidgets('Modo Clásico navega a su pantalla inicial',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Modo Clásico'));
    await tester.pumpAndSettle();

    expect(find.text('Comenzar'), findsOneWidget);
    expect(find.text('Tu récord: 0'), findsOneWidget);
  });

  testWidgets('un modo no disponible avisa que viene próximamente',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Desafío Diario'));
    await tester.pump();

    expect(find.textContaining('próximamente'), findsWidgets);

    // Dejar que el SnackBar se cierre solo para no dejar timers pendientes.
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('Comenzar arranca la partida y pasa a la fase de input',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Modo Clásico'));
    await tester.pumpAndSettle();

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

  testWidgets('elegir un modo daltónico activa las texturas en la vista previa',
      (WidgetTester tester) async {
    // Viewport alto para que todas las opciones queden visibles sin scroll.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Modo daltónico'), findsOneWidget);

    // Sin modo elegido no hay texturas.
    expect(find.byKey(const ValueKey<String>('pattern_red')), findsNothing);

    await tester.tap(find.text('Deuteranopía'));
    await tester.pump();

    // La vista previa ahora pinta el patrón de la ficha roja.
    expect(find.byKey(const ValueKey<String>('pattern_red')), findsOneWidget);
    expect(find.textContaining('cada una tiene su patrón'), findsOneWidget);
  });
}
