// Teste básico de smoke: garante que o app inicializa na tela de login
// mostrando o logo e o botão de criar conta.

import 'package:flutter_test/flutter_test.dart';

import 'package:lovic/main.dart';

void main() {
  testWidgets('LOVIC app abre na tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const LovicApp());

    expect(find.text('LOVIC'), findsOneWidget);
    expect(find.text('Bem-vindo!'), findsOneWidget);
    expect(find.text('Criar uma conta'), findsOneWidget);
  });
}
