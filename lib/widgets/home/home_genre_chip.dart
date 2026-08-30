import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/genre_colors.dart';

/// Pill de gênero musical usado na lista horizontal da Home
/// ("Explore gêneros musicais").
///
/// É um componente separado do [GenreChip] usado no card de perfil (Feed)
/// porque lá o chip fica dentro de um [Wrap], e um [Container] com
/// `alignment` dentro de um [Wrap] se estica pra ocupar a largura toda do
/// card (efeito colateral conhecido do Flutter). Aqui a altura é fixa e o
/// texto fica sempre centrado, sem esse risco, porque a largura continua
/// livre (a lista é horizontal).
class HomeGenreChip extends StatelessWidget {
  final String label;
  final GenreVariant variant;

  const HomeGenreChip({super.key, required this.label, required this.variant});

  @override
  Widget build(BuildContext context) {
    final colors = GenreColors.of(variant);
    final avgLuminance =
        (colors.first.computeLuminance() + colors.last.computeLuminance()) / 2;
    final textColor = avgLuminance > 0.55 ? Colors.black87 : Colors.white;

    return Container(
      height: 30,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: AppTextStyles.bodyBold.copyWith(fontSize: 10, color: textColor)),
    );
  }
}
