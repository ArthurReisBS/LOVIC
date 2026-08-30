import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Fundo em gradiente radial sutil usado em todas as telas do app.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.3,
          colors: [AppColors.backgroundEnd, AppColors.backgroundStart],
        ),
      ),
      child: child,
    );
  }
}
