import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/genre_colors.dart';

/// Pill colorido com o nome de um gênero musical, com gradiente conforme a
/// variante em [GenreColors].
class GenreChip extends StatelessWidget {
  final String label;
  final GenreVariant variant;

  const GenreChip({super.key, required this.label, required this.variant});

  @override
  Widget build(BuildContext context) {
    final colors = GenreColors.of(variant);
    final avgLuminance =
        (colors.first.computeLuminance() + colors.last.computeLuminance()) / 2;
    final textColor = avgLuminance > 0.55 ? Colors.black87 : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: AppTextStyles.bodyBold.copyWith(fontSize: 10, color: textColor)),
    );
  }
}
