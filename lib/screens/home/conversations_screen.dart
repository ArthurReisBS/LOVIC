import 'package:flutter/material.dart';
import '../../core/navigation/app_tabs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_profile.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/hover_scale.dart';
import '../../widgets/shared/lovic_logo.dart';

/// Uma prévia de conversa: perfil + última mensagem trocada + horário.
class _ConversationPreview {
  final UserProfile profile;
  final String lastMessage;
  final String time;

  const _ConversationPreview({required this.profile, required this.lastMessage, required this.time});
}

/// Tela de conversas — guarda os matches/mensagens do usuário.
/// Ainda mockada, sem integração real de chat/backend.
class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  static final List<_ConversationPreview> _conversations = [
    _ConversationPreview(profile: mockProfiles[0], lastMessage: 'Olá! Tudo bem?', time: '15:43'),
    _ConversationPreview(profile: mockProfiles[1], lastMessage: 'Olá! Tudo bem?', time: '15:43'),
    _ConversationPreview(profile: mockProfiles[2], lastMessage: 'Olá! Tudo bem?', time: '15:43'),
  ];

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
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Chats', style: AppTextStyles.heading),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: _conversations.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _ConversationTile(conversation: _conversations[index]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (index) => goToTab(context, index),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final _ConversationPreview conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final profile = conversation.profile;
    return HoverScale(
      scale: 1.02,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: profile.photoColor,
              backgroundImage: profile.photoAsset != null ? AssetImage(profile.photoAsset!) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: AppTextStyles.bodyBold),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage,
                    style: AppTextStyles.hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(conversation.time, style: AppTextStyles.hint),
          ],
        ),
      ),
    );
  }
}
