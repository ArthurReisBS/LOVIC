import 'package:flutter/material.dart';

/// Seta de voltar padrão do app. Só aparece quando há uma tela anterior para
/// voltar (nas telas raiz, como a Home depois do login, não mostra nada).
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Voltar',
      onPressed: () => Navigator.of(context).maybePop(),
      icon: const Icon(Icons.chevron_left),
    );
  }
}
