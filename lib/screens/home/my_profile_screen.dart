import 'package:flutter/material.dart';
import '../../core/navigation/app_tabs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/genre_colors.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/home/genre_chip.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/lovic_logo.dart';
import 'edit_profile_screen.dart';

/// Tela "Meu Perfil" — o perfil do próprio usuário logado. Nome, username e
/// bio vêm do Supabase; os gêneros seguem mockados até a integração com o
/// Spotify (CP06). Sem login real, mostra o placeholder "Você".
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  MyProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Se o perfil não existir ou der erro, segue com o placeholder "Você".
  void _loadProfile() {
    AuthService.fetchMyProfile().then((profile) {
      if (mounted) setState(() => _profile = profile);
    }, onError: (_) {});
  }

  Future<void> _editProfile() async {
    final saved = await openEditProfile(context);
    if (saved && mounted) _loadProfile();
  }

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
                  child: Text(
                    _initial,
                    style: AppTextStyles.screenTitle.copyWith(
                      fontSize: 40,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _profile?.nomeCompleto ?? 'Você',
                  style: AppTextStyles.heading,
                ),
                if (_profile != null) ...[
                  const SizedBox(height: 4),
                  Text('@${_profile!.username}', style: AppTextStyles.hint),
                ],
                const SizedBox(height: 8),
                Text(
                  _profile?.bio ??
                      'Adicione uma bio pra galera saber o que você curte ouvir.',
                  style: AppTextStyles.hint,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _myGenres
                      .map((g) => GenreChip(label: g.name, variant: g.variant))
                      .toList(),
                ),
                const SizedBox(height: 32),
                GradientButton(label: 'Editar perfil', onPressed: _editProfile),
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

  String get _initial {
    final nome = _profile?.nome ?? '';
    return nome.isEmpty ? 'V' : nome[0].toUpperCase();
  }
}
