import 'package:flutter/material.dart';

/// Paleta de cores do LOVIC, replicada do design system definido no Figma
/// pelo designer do grupo ("Paleta de cores - Sistema" e
/// "Paleta de cores - Logo/App Icon").
class AppColors {
  AppColors._();

  // Fundo (gradiente radial sutil, usado em todas as telas)
  static const Color backgroundStart = Color(0xFF202020);
  static const Color backgroundEnd = Color(0xFF252525);

  // Cor de destaque principal
  static const Color primary = Color(0xFFFF9A42);

  // Gradiente dos botões principais (Confirmar, Avançar, Criar conta,
  // Encontre um par) e do ícone ativo da navegação
  static const Color specialGradientStart = Color(0xFFFF9A42);
  static const Color specialGradientEnd = Color(0xFFFFDB97);

  // Texto
  static const Color textPrimary = Color(0xFFFEFEFE);
  static const Color textSecondary = Color(0xFF202020);

  // Ícones não selecionados / placeholders (tabela "Layout - Icons")
  static const Color iconInactive = Color(0xFF555555);
  static const Color textMuted = Color(0xFF707070);

  // Blobs do logo/fundo desfocado
  static const Color blobYellow = Color(0xFFFFE682);
  static const Color blobOrange = Color(0xFFFF9A42);
  static const Color blobPink = Color(0xFFFFA2FD);

  // Blobs decorativos do card de perfil (Feed)
  static const Color blobGreen = Color(0xFF4CD964);
  static const Color blobRed = Color(0xFFFF5252);

  // Superfícies e bordas neutras
  static const Color surfaceDark = Color(0xFF2A2A2A);
  static const Color fieldBorderNeutral = Color(0xFF4A4A4A);

  // Botões sociais
  static const Color socialButtonLight = Color(0xFFF5F5F5);
  static const Color socialButtonSpotify = Color(0xFE474747);
  static const Color spotifyGreen = Color(0xFF1DB954);

  // Placeholder visual de mapa (Home)
  static const Color mapBackground = Color(0xFFE9E9EA);
  static const Color mapRoad = Color(0xFFD3D3D6);
  static const Color mapHeatPink = Color(0xFFFFA2FD);
  static const Color mapHeatYellow = Color(0xFFFFDB97);
}
