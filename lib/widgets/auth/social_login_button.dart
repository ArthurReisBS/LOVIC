import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/hover_scale.dart';

/// Botão de login/cadastro social (Google, Spotify), com ícone à esquerda
/// e texto centralizado.
class SocialLoginButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.textColor = Colors.black87,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return HoverScale(
      scale: 1.03,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed ?? () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(alignment: Alignment.centerLeft, child: icon),
              Text(label, style: AppTextStyles.bodyBold.copyWith(color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}
