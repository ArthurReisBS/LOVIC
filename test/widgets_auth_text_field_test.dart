import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovic/widgets/auth/auth_text_field.dart';

void main() {
  testWidgets('campo de senha tem olhinho que mostra e esconde o texto', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthTextField(hintText: 'senha', obscureText: true),
        ),
      ),
    );

    bool obscured() =>
        tester.widget<TextField>(find.byType(TextField)).obscureText;

    expect(obscured(), isTrue);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(obscured(), isFalse);
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(obscured(), isTrue);
  });

  testWidgets('campo comum não mostra olhinho', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AuthTextField(hintText: 'email'))),
    );
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);
  });
}
