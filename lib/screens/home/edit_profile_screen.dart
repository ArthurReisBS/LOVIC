import 'package:flutter/material.dart';
import '../../core/config/supabase_config.dart';
import '../../core/navigation/no_transition_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/ui/em_breve.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/gradient_blob_background.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/shared/lovic_logo.dart';

/// Abre a edição de perfil e devolve `true` se algo foi salvo. Sem banco
/// (modo demonstração) só avisa que precisa do `.env`.
Future<bool> openEditProfile(BuildContext context) async {
  if (!SupabaseConfig.isConfigured) {
    mostrarEmBreve(context, 'Conecte o banco (.env) para editar o perfil.');
    return false;
  }
  final saved = await Navigator.of(
    context,
  ).push<bool>(noTransitionRoute(const EditProfileScreen()));
  return saved ?? false;
}

/// Edita nome, sobrenome e bio do usuário logado. O username não muda.
/// Ao salvar com sucesso, fecha a tela devolvendo `true`.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _bioMaxLength = 200;

  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _bio = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _surname.dispose();
    _bio.dispose();
    super.dispose();
  }

  /// Preenche os campos com o perfil atual.
  Future<void> _load() async {
    try {
      final profile = await AuthService.fetchMyProfile();
      if (!mounted) return;
      if (profile == null) {
        _showMessage('Não encontramos seu perfil.');
        Navigator.pop(context);
        return;
      }
      _name.text = profile.nome;
      _surname.text = profile.sobrenome ?? '';
      _bio.text = profile.bio ?? '';
      setState(() => _loading = false);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
      Navigator.pop(context);
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return _showMessage('Digite seu nome.');
    setState(() => _saving = true);
    try {
      await AuthService.updateMyProfile(
        nome: _name.text,
        sobrenome: _surname.text,
        bio: _bio.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(e.message);
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBlobBackground(
        blobScale: .58,
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.chevron_left),
                        ),
                      ),
                      const Center(child: LovicLogo(fontSize: 38)),
                      const SizedBox(height: 32),
                      Center(
                        child: Text('Editar perfil', style: AppTextStyles.heading),
                      ),
                      const SizedBox(height: 32),
                      Text('Nome:', style: AppTextStyles.bodyBold),
                      const SizedBox(height: 10),
                      AuthTextField(
                        controller: _name,
                        hintText: 'Digite seu nome...',
                      ),
                      const SizedBox(height: 24),
                      Text('Sobrenome:', style: AppTextStyles.bodyBold),
                      const SizedBox(height: 10),
                      AuthTextField(
                        controller: _surname,
                        hintText: 'Digite seu sobrenome...',
                      ),
                      const SizedBox(height: 24),
                      Text('Bio:', style: AppTextStyles.bodyBold),
                      const SizedBox(height: 10),
                      AuthTextField(
                        controller: _bio,
                        hintText: 'Conte o que você curte ouvir...',
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                        maxLength: _bioMaxLength,
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        label: _saving ? 'Salvando...' : 'Salvar',
                        onPressed: _saving ? null : _save,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
