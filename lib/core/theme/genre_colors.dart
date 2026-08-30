import 'package:flutter/material.dart';

/// Variantes de cor para gêneros musicais, replicadas da tabela
/// "Paleta de cores - Gêneros musicais" do Figma.
enum GenreVariant { v1, v2, v3, v4, v5 }

class GenreColors {
  GenreColors._();

  static const Map<GenreVariant, List<Color>> gradients = {
    GenreVariant.v1: [Color(0xFFFF9A42), Color(0xFFFFE682)], // Sertanejo
    GenreVariant.v2: [Color(0xFFFFA2FD), Color(0xFFDF38E8)], // Funk
    GenreVariant.v3: [Color(0xFFFFE682), Color(0xFFBED702)], // MPB
    GenreVariant.v4: [Color(0xFF60EFFF), Color(0xFF1999A7)],
    GenreVariant.v5: [Color(0xFFFF5757), Color(0xFFFFA4A4)],
  };

  static List<Color> of(GenreVariant variant) => gradients[variant]!;
}
