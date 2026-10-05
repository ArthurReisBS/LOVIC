import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovic/screens/home/settings_screen.dart';

void main() {
  Future<void> abrirConfiguracoes(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
  }

  testWidgets('Notificações mostra o aviso "Em breve"', (tester) async {
    await abrirConfiguracoes(tester);
    await tester.tap(find.text('Notificações'));
    await tester.pump();
    expect(find.text('Em breve!'), findsOneWidget);
  });

  testWidgets('Sair pede confirmação e, ao confirmar, volta ao login', (
    tester,
  ) async {
    await abrirConfiguracoes(tester);
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();
    expect(find.text('Deseja sair da conta?'), findsOneWidget);

    // Cancelar mantém nas Configurações.
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Configurações'), findsOneWidget);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Sair'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Bem-vindo!'), findsOneWidget);
  });
}
