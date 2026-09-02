// Pruebas del shell de la app: menú principal y navegación.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chroma_memory/app/app.dart';

void main() {
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

  testWidgets('Modo Clásico navega a su página',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Modo Clásico'));
    await tester.pumpAndSettle();

    expect(find.text('Modo Clásico'), findsOneWidget); // AppBar de la página
    expect(find.textContaining('se implementa en la'), findsOneWidget);
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
}
