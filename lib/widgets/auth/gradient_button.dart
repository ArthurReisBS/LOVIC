import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../shared/hover_scale.dart';

/// Botão principal full-width, cantos em pill e fundo em gradiente
/// laranja→amarelo — usado em "Confirmar", "Avançar", "Criar conta" e
/// "Encontre um par".
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;

  const GradientButton({super.key, required this.label, this.onPressed, this.height = 56});

  @override
  Widget build(BuildContext context) {
    return HoverScale(
      scale: 1.03,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [AppColors.specialGradientStart, AppColors.specialGradientEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: onPressed ?? () {},
              child: Center(
                child: Text(label, style: AppTextStyles.bodyBold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
