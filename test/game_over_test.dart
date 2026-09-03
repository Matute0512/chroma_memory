// Pantalla de Game Over: celebración (confeti) según el desenlace y hook de
// "2ª oportunidad" (oculto cuando el reto diario ya se completó).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chroma_memory/core/constants/themes.dart';
import 'package:chroma_memory/features/classic_mode/presentation/pages/classic_results_page.dart';
import 'package:chroma_memory/features/classic_mode/presentation/viewmodels/classic_viewmodel.dart';
import 'package:chroma_memory/shared/presentation/widgets/confetti_burst.dart';

ClassicState stateWith({
  bool isNewBest = false,
  bool completed = false,
  int score = 9,
  int round = 5,
}) => ClassicState.initial().copyWith(
  phase: ClassicPhase.gameOver,
  isNewBest: isNewBest,
  completed: completed,
  score: score,
  round: round,
);

Future<void> pumpResults(WidgetTester tester, ClassicState state) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: ClassicResultsPage(state: state),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));
}

void main() {
  testWidgets('nuevo récord muestra confeti y la 2ª oportunidad', (
    WidgetTester tester,
  ) async {
    await pumpResults(tester, stateWith(isNewBest: true, score: 24));

    expect(find.text('¡Nuevo récord!'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.byType(ConfettiBurst), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.textContaining('2ª oportunidad'), findsOneWidget);

    // El hook avisa (todavía no hay SDK de anuncios).
    await tester.tap(find.textContaining('2ª oportunidad'));
    await tester.pump();
    expect(find.text('La 2ª oportunidad llega pronto.'), findsOneWidget);
    // Deja que el SnackBar se cierre solo antes de terminar el test.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('reto completado celebra pero no ofrece 2ª oportunidad', (
    WidgetTester tester,
  ) async {
    await pumpResults(tester, stateWith(completed: true));

    expect(find.text('¡Reto completado!'), findsOneWidget);
    expect(find.text('Completaste el reto de hoy.'), findsOneWidget);
    expect(find.byType(ConfettiBurst), findsOneWidget);
    expect(find.textContaining('2ª oportunidad'), findsNothing);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('fin de partida común: sin confeti pero con 2ª oportunidad', (
    WidgetTester tester,
  ) async {
    await pumpResults(tester, stateWith(round: 7));

    expect(find.text('Fin de la partida'), findsOneWidget);
    expect(find.byType(ConfettiBurst), findsNothing);
    expect(find.textContaining('2ª oportunidad'), findsOneWidget);
    expect(find.text('Llegaste a la ronda 7'), findsOneWidget);
  });
}
