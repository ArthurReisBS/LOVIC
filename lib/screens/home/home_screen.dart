import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/navigation/app_tabs.dart';
import '../../core/navigation/no_transition_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/genre_colors.dart';
import '../../models/user_profile.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/home/home_genre_chip.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/hover_scale.dart';
import '../../widgets/shared/lovic_logo.dart';
import 'profile_card_screen.dart';

/// Tela inicial: busca, mapa, botão de match e gêneros musicais.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<ProfileGenre> _genres = [
    ProfileGenre('Sertanejo', GenreVariant.v1),
    ProfileGenre('Funk', GenreVariant.v2),
    ProfileGenre('MPB', GenreVariant.v3),
    ProfileGenre('Pop', GenreVariant.v4),
    ProfileGenre('Rock', GenreVariant.v5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: const [
                      LovicLogo(fontSize: 34),
                      Positioned(right: 0, child: _NotificationBell()),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const _SearchBar(),
                const SizedBox(height: 24),
                const _MapWithBlobs(),
                const SizedBox(height: 10),
                Text('Localização atual', style: AppTextStyles.hint),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Encontre um par',
                  height: 50,
                  onPressed: () {
                    Navigator.of(context).push(noTransitionRoute(const ProfileCardScreen()));
                  },
                ),
                const SizedBox(height: 40),
                Text('Explore gêneros musicais', style: AppTextStyles.bodyBold),
                const SizedBox(height: 18),
                SizedBox(
                  height: 30,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _genres.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final genre = _genres[index];
                      return HomeGenreChip(label: genre.name, variant: genre.variant);
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) => goToTab(context, index),
      ),
    );
  }
}

/// Sino de notificações com badge, no canto superior direito da Home.
/// Ainda decorativo, sem tela de notificações por trás.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none, color: Colors.white70, size: 26),
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            width: 14,
            height: 14,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Text(
              '3',
              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        style: AppTextStyles.body,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: InputBorder.none,
          hintText: 'Procure um lugar...',
          hintStyle: AppTextStyles.hint,
          suffixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
        ),
      ),
    );
  }
}

/// Mapa real (print estático) com bolhas desfocadas rosa/amarelo por cima,
/// igual à referência, e um botão de localizar — sem integração real de
/// mapa/GPS ainda.
class _MapWithBlobs extends StatelessWidget {
  const _MapWithBlobs();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 240,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/map_placeholder.png', fit: BoxFit.cover),
            Positioned(top: -20, left: -10, child: _heatBlob(140, AppColors.mapHeatPink)),
            Positioned(bottom: -30, left: 70, child: _heatBlob(160, AppColors.mapHeatYellow)),
            Positioned(
              right: 12,
              bottom: 12,
              child: HoverScale(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.my_location, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heatBlob(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.55), shape: BoxShape.circle),
      ),
    );
  }
}
