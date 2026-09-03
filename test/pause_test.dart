// Pausa del HUD: solo durante el turno del jugador (fase input), congela la
// partida y el overlay permite reanudar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chroma_memory/app/app.dart';
import 'package:chroma_memory/core/utils/audio_manager.dart';

/// Espera una transición de ruta con pumps discretos (la Home anima en bucle).
Future<void> settle(
  WidgetTester tester, [
  Duration duration = const Duration(milliseconds: 400),
]) async {
  await tester.pump();
  await tester.pump(duration);
  await tester.pump();
}

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: ChromaMemoryApp()));
  await tester.pump(const Duration(milliseconds: 1001)); // splash → Home
  await settle(tester);
}

/// Lleva la partida a la fase de input (turno del jugador).
Future<void> startGameToInput(WidgetTester tester) async {
  await tester.tap(find.text('Modo Clásico'));
  await settle(tester);
  await tester.tap(find.text('Comenzar'));
  await tester.pump(); // dispara newGame (fase watching).

  // Ronda 1 = 2 colores, ~700 ms por destello.
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(seconds: 2));
  expect(find.text('Tu turno: repetí la secuencia'), findsOneWidget);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AudioManager.instance.enabled = false;
  });

  testWidgets('durante la revelación no hay botón de pausa', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Modo Clásico'));
    await settle(tester);
    await tester.tap(find.text('Comenzar'));
    await tester.pump();

    expect(find.text('Prestá atención…'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsNothing);

    // Consume la revelación (ronda 1 = 2 colores) para no dejar timers vivos.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('pausar en el turno congela la partida y reanuda', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await startGameToInput(tester);

    // Pausar: aparece el overlay.
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(find.text('En pausa'), findsOneWidget);
    expect(find.text('Reanudar'), findsOneWidget);

    // El overlay persiste mientras esté pausada (el motor, además, ignora
    // toques con paused=true).
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('En pausa'), findsOneWidget);

    // Reanudar vuelve exactamente al turno del jugador.
    await tester.tap(find.text('Reanudar'));
    await tester.pump();
    expect(find.text('En pausa'), findsNothing);
    expect(find.text('Tu turno: repetí la secuencia'), findsOneWidget);
  });
}
