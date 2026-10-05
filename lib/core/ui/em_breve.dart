import 'package:flutter/material.dart';

/// Avisa que o botão ainda não tem função (depende de algo do CP06).
void mostrarEmBreve(BuildContext context, [String mensagem = 'Em breve!']) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mensagem)));
}
