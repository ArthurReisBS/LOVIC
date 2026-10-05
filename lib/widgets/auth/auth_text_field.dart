import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Campo de texto pill das telas de autenticação: fundo transparente/escuro
/// e borda arredondada laranja por padrão (a tela de data de nascimento usa
/// [borderColor] neutro).
class AuthTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final Color borderColor;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  /// Para campos multilinha (bio). [maxLength] mostra o contador de caracteres.
  final int maxLines;
  final int? maxLength;

  const AuthTextField({
    super.key,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.borderColor = AppColors.primary,
    this.suffixIcon,
    this.onTap,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      readOnly: readOnly,
      onTap: onTap,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.hint,
        filled: true,
        fillColor: Colors.transparent,
        suffixIcon: suffixIcon,
        counterStyle: AppTextStyles.hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
      ),
    );
  }
}
