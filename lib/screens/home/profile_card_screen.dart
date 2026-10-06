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
import '../../widgets/shared/app_back_button.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/lovic_logo.dart';
import 'chat_talk_screen.dart';
import 'profile_detail_screen.dart';

/// Feed de perfis: com banco mostra as outras pessoas cadastradas; sem banco
/// (modo demonstração) mostra os perfis de exemplo.
class ProfileCardScreen extends StatefulWidget {
  /// Quando informado, só aparecem pessoas que curtem esse gênero.
  final String? genreFilter;

  const ProfileCardScreen({super.key, this.genreFilter});

  @override
  State<ProfileCardScreen> createState() => _ProfileCardScreenState();
}

class _ProfileCardScreenState extends State<ProfileCardScreen> {
  final _controller = PageController();
  List<UserProfile> _profiles = const [];
  bool _loading = true;
  String? _error;
  String? _genreFilter;

  @override
  void initState() {
    super.initState();
    _genreFilter = widget.genreFilter;
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

  List<UserProfile> get _visibleProfiles {
    final filter = _genreFilter?.toLowerCase();
    if (filter == null) return _profiles;
    return _profiles
        .where((p) => p.genres.any((g) => g.name.toLowerCase() == filter))
        .toList();
  }

  void _clearFilter() {
    setState(() => _genreFilter = null);
    if (_controller.hasClients) _controller.jumpToPage(0);
  }

  Widget _filterBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'Filtrando por: $_genreFilter',
            style: AppTextStyles.bodyBold,
          ),
        ),
        TextButton.icon(
          onPressed: _clearFilter,
          icon: const Icon(Icons.close, size: 16, color: AppColors.primary),
          label: Text('Tirar filtro', style: AppTextStyles.linkOrange),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 4),
              Stack(
                alignment: Alignment.center,
                children: [
                  const LovicLogo(fontSize: 22),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (_genreFilter != null) _filterBar(),
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
    final profiles = _visibleProfiles;
    if (profiles.isEmpty) {
      return _Message(
        text: _genreFilter != null
            ? 'Ninguém curte $_genreFilter por enquanto.'
            : 'Ainda não há outras pessoas por aqui. '
                  'Convide alguém para criar uma conta!',
        actionLabel: _genreFilter != null ? 'Tirar filtro' : null,
        onAction: _clearFilter,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: PageView.builder(
        controller: _controller,
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final p = profiles[index];
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
