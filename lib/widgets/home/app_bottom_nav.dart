import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../shared/hover_scale.dart';

/// Barra de navegação inferior fixa: perfil, curtidas, home, chat e
/// configurações. Segue a tabela "Layout - Icons": ícone ativo em gradiente
/// laranja, inativo em cinza (#555555), sem fundo/badge.
///
/// Índices: 0 = perfil, 1 = curtidas/descobrir, 2 = home, 3 = chat,
/// 4 = configurações. O ícone de home é uma imagem customizada (não um
/// ícone do Material) — os demais usam os ícones padrão do Flutter.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNav({super.key, this.currentIndex = 2, this.onTap});

  static const int _homeIndex = 2;
  static const List<IconData?> _icons = [
    Icons.person_outline,
    Icons.favorite_border,
    null, // home: usa a imagem customizada em assets/images/home_icon.png
    Icons.chat_bubble_outline,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _icons.length,
          (index) => _navIcon(icon: _icons[index], index: index),
        ),
      ),
    );
  }

  Widget _navIcon({required IconData? icon, required int index}) {
    final bool active = index == currentIndex;
    final Color tint = active ? Colors.white : AppColors.iconInactive;

    final Widget iconWidget = index == _homeIndex
        ? Image.asset(
            'assets/images/home_icon.png',
            width: 24,
            height: 24,
            color: tint,
            colorBlendMode: BlendMode.srcIn,
          )
        : Icon(icon, color: tint, size: 24);

    return HoverScale(
      child: IconButton(
        onPressed: onTap == null ? null : () => onTap!(index),
        icon: active
            ? ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.specialGradientStart, AppColors.specialGradientEnd],
                ).createShader(bounds),
                child: iconWidget,
              )
            : iconWidget,
      ),
    );
  }
}
