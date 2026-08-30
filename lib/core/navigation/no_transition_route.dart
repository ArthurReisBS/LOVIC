import 'package:flutter/material.dart';

/// Rota sem nenhuma animação de transição entre telas (a troca acontece na
/// hora, sem slide/fade).
PageRoute<T> noTransitionRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}
