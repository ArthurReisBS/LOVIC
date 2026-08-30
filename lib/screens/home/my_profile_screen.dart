import 'package:flutter/material.dart';
import '../../core/navigation/app_tabs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/genre_colors.dart';
import '../../models/user_profile.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/home/genre_chip.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/lovic_logo.dart';

/// Tela "Meu Perfil" — o perfil do próprio usuário logado (ainda mockado,
/// sem edição real).
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  static const List<ProfileGenre> _myGenres = [
    ProfileGenre('Sertanejo', GenreVariant.v1),
    ProfileGenre('Pop', GenreVariant.v4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              children: [
                const LovicLogo(fontSize: 34),
                const SizedBox(height: 28),
                Container(
                  width: 108,
                  height: 108,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blobYellow,
                  ),
                  alignment: Alignment.center,
                  child: Text('V', style: AppTextStyles.screenTitle.copyWith(fontSize: 40, color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 16),
                Text('Você', style: AppTextStyles.heading),
                const SizedBox(height: 8),
                Text(
                  'Adicione uma bio pra galera saber o que você curte ouvir.',
                  style: AppTextStyles.hint,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _myGenres.map((g) => GenreChip(label: g.name, variant: g.variant)).toList(),
                ),
                const SizedBox(height: 32),
                GradientButton(label: 'Editar perfil'),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) => goToTab(context, index),
      ),
    );
  }
}
