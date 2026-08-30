import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../shared/app_background.dart';

/// Fundo com três "bolhas" desfocadas se sobrepondo atrás do logo LOVIC —
/// amarelo-dourada maior em cima, laranja no meio e rosa/magenta embaixo,
/// deslocada para a direita.
///
/// [blobScale] encolhe as bolhas nas telas de registro do meio do fluxo
/// (2-5), que usam um logo mais compacto.
/// [scattered] adiciona 2-3 bolhas extras de baixa opacidade espalhadas
/// pelos cantos da tela (usado na tela "Fale um pouco sobre você").
class GradientBlobBackground extends StatelessWidget {
  final Widget child;
  final double blobScale;
  final bool scattered;

  const GradientBlobBackground({
    super.key,
    required this.child,
    this.blobScale = 1.0,
    this.scattered = false,
  });

  @override
  Widget build(BuildContext context) {
    final yellowSize = 220 * blobScale;
    final orangeSize = 150 * blobScale;
    final pinkSize = 170 * blobScale;

    return AppBackground(
      child: Stack(
        children: [
          if (scattered) ..._scatteredBlobs(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: yellowSize + pinkSize * 0.6,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: _blob(yellowSize, AppColors.blobYellow),
                  ),
                  Positioned(
                    top: yellowSize * 0.3,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: const Alignment(0.65, 0),
                      child: _blob(orangeSize, AppColors.blobOrange),
                    ),
                  ),
                  Positioned(
                    top: yellowSize * 0.45,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: const Alignment(0.4, 0),
                      child: _blob(pinkSize, AppColors.blobPink),
                    ),
                  ),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  List<Widget> _scatteredBlobs() {
    return const [
      Positioned(top: 60, left: -50, child: _LowOpacityBlob(size: 150, color: AppColors.blobYellow)),
      Positioned(bottom: 140, left: -40, child: _LowOpacityBlob(size: 140, color: AppColors.primary)),
      Positioned(bottom: -30, right: -40, child: _LowOpacityBlob(size: 170, color: Color(0xFF4FA8E0))),
    ];
  }

  Widget _blob(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.85)),
      ),
    );
  }
}

class _LowOpacityBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _LowOpacityBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.22)),
      ),
    );
  }
}
