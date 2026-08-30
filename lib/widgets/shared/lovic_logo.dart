import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

/// Wordmark "LOVIC", reutilizado no topo de todas as telas.
///
/// [fontSize] permite variantes menores/compactas (telas de registro 2-5,
/// header da Home e do Feed) sem duplicar o estilo base.
class LovicLogo extends StatelessWidget {
  final double fontSize;

  const LovicLogo({super.key, this.fontSize = 80});

  @override
  Widget build(BuildContext context) {
    return Text('LOVIC', style: AppTextStyles.logo.copyWith(fontSize: fontSize));
  }
}
