import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurofit_frontend/pages/dashboard_page.dart';

void main() {
  testWidgets('DashboardPage renderiza los apartados principales', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardPage(),
      ),
    );

    expect(find.text('Ambiente de Evaluación Motriz Avanzada'), findsOneWidget);
    expect(find.text('Inicio rápido'), findsOneWidget);
    expect(find.text('EXPLORAR TECNOLOGÍA'), findsOneWidget);
    expect(find.text('VER HISTORIAL'), findsOneWidget);
    expect(find.text('FUNCIONALIDADES'), findsOneWidget);
    expect(find.text('SECCIÓN DE RIESGO'), findsOneWidget);
    expect(find.text('SOBRE MOTORSENSE'), findsOneWidget);
  });
}
