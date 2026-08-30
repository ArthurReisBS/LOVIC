import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Estilos de texto do LOVIC — fonte Poppins no corpo do app e Rammetto One
/// no wordmark "LOVIC", seguindo os 4 tamanhos padrão do design system: 14
/// (corpo/labels), 24 (subtítulos), 48 (títulos de tela) e 80 (logo/destaque).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get logo => GoogleFonts.rammettoOne(
        fontSize: 50,
        color: AppColors.textPrimary,
      );

  static TextStyle get screenTitle => GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get heading => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyBold => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get hint => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get linkOrange => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.primary,
      );
}
