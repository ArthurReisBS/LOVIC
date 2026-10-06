import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Campo de texto pill das telas de autenticação: fundo escuro translúcido
/// (para o texto continuar legível sobre o gradiente colorido) e borda
/// arredondada laranja por padrão (a tela de data de nascimento usa
/// [borderColor] neutro). Em campos de senha ([obscureText]) aparece o
/// "olhinho" para mostrar/esconder o texto.
class AuthTextField extends StatefulWidget {
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
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _hidden = widget.obscureText;

  Widget? get _suffix {
    if (!widget.obscureText) return widget.suffixIcon;
    return IconButton(
      tooltip: _hidden ? 'Mostrar senha' : 'Esconder senha',
      onPressed: () => setState(() => _hidden = !_hidden),
      icon: Icon(
        _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Colors.white70,
        size: 20,
      ),
    );
  }

  OutlineInputBorder _border([double width = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(28),
    borderSide: BorderSide(color: widget.borderColor, width: width),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _hidden,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      cursorColor: AppColors.primary,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTextStyles.body.copyWith(color: Colors.white60),
        filled: true,
        fillColor: AppColors.backgroundStart.withValues(alpha: .88),
        suffixIcon: _suffix,
        counterStyle: AppTextStyles.hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(2),
      ),
    );
  }
}
