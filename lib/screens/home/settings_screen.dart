import 'package:flutter/material.dart';
import '../../core/navigation/app_tabs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/hover_scale.dart';
import '../../widgets/shared/lovic_logo.dart';

/// Tela de Configurações — lista simples de opções, ainda sem
/// funcionalidade real por trás.
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
              const _SettingsRow(icon: Icons.person_outline, label: 'Perfil'),
              const _SettingsRow(icon: Icons.notifications_none, label: 'Notificações'),
              const _SettingsRow(icon: Icons.visibility_outlined, label: 'Privacidade'),
              const _SettingsRow(icon: Icons.smartphone_outlined, label: 'Versão', trailing: 'v1.0.0'),
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

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;

  const _SettingsRow({required this.icon, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return HoverScale(
      scale: 1.01,
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
    );
  }
}
