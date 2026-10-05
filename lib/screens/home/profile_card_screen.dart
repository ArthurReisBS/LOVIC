import 'package:flutter/material.dart';
import '../../core/navigation/app_tabs.dart';
import '../../core/navigation/no_transition_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/ui/em_breve.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/home/profile_card.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/lovic_logo.dart';
import 'chat_talk_screen.dart';
import 'profile_detail_screen.dart';

/// Feed de perfis: com banco mostra as outras pessoas cadastradas; sem banco
/// (modo demonstração) mostra os perfis de exemplo.
class ProfileCardScreen extends StatefulWidget {
  const ProfileCardScreen({super.key});

  @override
  State<ProfileCardScreen> createState() => _ProfileCardScreenState();
}

class _ProfileCardScreenState extends State<ProfileCardScreen> {
  final _controller = PageController();
  List<UserProfile> _profiles = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profiles = await AuthService.fetchOtherProfiles();
      if (!mounted) return;
      setState(() {
        _profiles = profiles;
        _loading = false;
      });
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      // Qualquer outra falha (ex.: linha inesperada) também não trava o loading.
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível carregar os perfis.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 4),
              const LovicLogo(fontSize: 22),
              const SizedBox(height: 4),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (i) => goToTab(context, i),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return _Message(
        text: _error!,
        actionLabel: 'Tentar de novo',
        onAction: _load,
      );
    }
    if (_profiles.isEmpty) {
      return const _Message(
        text: 'Ainda não há outras pessoas por aqui. '
            'Convide alguém para criar uma conta!',
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: PageView.builder(
        controller: _controller,
        itemCount: _profiles.length,
        itemBuilder: (context, index) {
          final p = _profiles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ProfileCard(
              profile: p,
              onViewProfile: () => Navigator.of(context).push(
                noTransitionRoute(ProfileDetailScreen(profile: p)),
              ),
              onMessage: () => Navigator.of(context).push(
                noTransitionRoute(ChatTalkScreen(profile: p)),
              ),
              onLocation: () =>
                  mostrarEmBreve(context, 'Localização chega no CP06.'),
            ),
          );
        },
      ),
    );
  }
}

/// Texto centralizado (vazio ou erro), com botão opcional.
class _Message extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({required this.text, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: AppTextStyles.body, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel!, style: AppTextStyles.linkOrange),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
