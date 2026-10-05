import 'package:flutter/material.dart';
import '../../core/config/supabase_config.dart';
import '../../core/navigation/app_tabs.dart';
import '../../core/navigation/no_transition_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/ui/em_breve.dart';
import '../../services/auth_service.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/hover_scale.dart';
import '../../widgets/shared/lovic_logo.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

/// Tela de Configurações — lista de opções. Perfil e Sair funcionam;
/// Notificações e Privacidade avisam "Em breve".
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Center(child: LovicLogo(fontSize: 32)),
              const SizedBox(height: 24),
              Center(child: Text('Configurações', style: AppTextStyles.heading)),
              const SizedBox(height: 24),
              _SettingsRow(
                icon: Icons.person_outline,
                label: 'Perfil',
                onTap: () => openEditProfile(context),
              ),
              _SettingsRow(
                icon: Icons.notifications_none,
                label: 'Notificações',
                onTap: () => mostrarEmBreve(context),
              ),
              _SettingsRow(
                icon: Icons.visibility_outlined,
                label: 'Privacidade',
                onTap: () => mostrarEmBreve(context),
              ),
              const _SettingsRow(icon: Icons.smartphone_outlined, label: 'Versão', trailing: 'v1.0.0'),
              _SettingsRow(
                icon: Icons.logout,
                label: 'Sair',
                onTap: () => _confirmSignOut(context),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 4,
        onTap: (index) => goToTab(context, index),
      ),
    );
  }
}

/// Pergunta antes de sair; ao confirmar encerra a sessão e volta ao login.
Future<void> _confirmSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      title: Text('Deseja sair da conta?', style: AppTextStyles.bodyBold),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text('Cancelar', style: AppTextStyles.hint),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text('Sair', style: AppTextStyles.linkOrange),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  // Em modo demonstração não há sessão: só volta ao login.
  if (SupabaseConfig.isConfigured) {
    try {
      await AuthService.signOut();
    } catch (_) {
      if (context.mounted) {
        mostrarEmBreve(context, 'Não foi possível sair agora. Tente de novo.');
      }
      return;
    }
    if (!context.mounted) return;
  }
  Navigator.of(context).pushAndRemoveUntil(
    noTransitionRoute(const LoginScreen()),
    (_) => false,
  );
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HoverScale(
      scale: 1.01,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 22),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: AppTextStyles.body)),
              if (trailing != null) Text(trailing!, style: AppTextStyles.hint),
            ],
          ),
        ),
      ),
    );
  }
}
