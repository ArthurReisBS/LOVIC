import 'package:flutter/material.dart';
import '../../core/navigation/app_tabs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/music_genres.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/home/genre_chip.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/lovic_logo.dart';
import 'edit_profile_screen.dart';

/// Tela "Meu Perfil" — o perfil do próprio usuário logado. Nome, username e
/// bio vêm do Supabase; gêneros, informações e fotos também. Sem login real, mostra o placeholder "Você".
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
                CircleAvatar(
                  radius: 54,
                  backgroundColor: AppColors.blobYellow,
                  backgroundImage: _profile?.fotoUrl != null
                      ? NetworkImage(_profile!.fotoUrl!)
                      : null,
                  child: _profile?.fotoUrl == null
                      ? Text(
                          _initial,
                          style: AppTextStyles.screenTitle.copyWith(
                            fontSize: 40,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
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
                  children: (_profile?.generos ?? const <String>[])
                      .map(genreFromName)
                      .map((g) => GenreChip(label: g.name, variant: g.variant))
                      .toList(),
                ),
                if (_infos.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Informações pessoais',
                      style: AppTextStyles.heading,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final info in _infos)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '${info.$1}: ${info.$2}',
                          style: AppTextStyles.body,
                        ),
                      ),
                    ),
                ],
                if ((_profile?.fotos ?? const <String>[]).isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Fotos', style: AppTextStyles.heading),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final url in _profile!.fotos)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            url,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ],
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

  List<(String, String)> get _infos => [
    if (_profile?.genero != null) ('Gênero', _profile!.genero!),
    if (_profile?.sexualidade != null) ('Sexualidade', _profile!.sexualidade!),
    if (_profile?.alturaCm != null)
      ('Altura', '${(_profile!.alturaCm! / 100).toStringAsFixed(2).replaceAll('.', ',')} m'),
  ];

  String get _initial {
    final nome = _profile?.nome ?? '';
    return nome.isEmpty ? 'V' : nome[0].toUpperCase();
  }
}
