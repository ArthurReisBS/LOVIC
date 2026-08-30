import 'package:flutter/material.dart';
import '../../core/navigation/app_tabs.dart';
import '../../models/user_profile.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/home/profile_card.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/lovic_logo.dart';

/// Tela de card de perfil: navega pelos perfis mockados, um por vez,
/// em formato de foto cheia com informações sobrepostas.
class ProfileCardScreen extends StatefulWidget {
  const ProfileCardScreen({super.key});

  @override
  State<ProfileCardScreen> createState() => _ProfileCardScreenState();
}

class _ProfileCardScreenState extends State<ProfileCardScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: mockProfiles.length,
                    itemBuilder: (context, index) {
                      final profile = mockProfiles[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ProfileCard(profile: profile),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) => goToTab(context, index),
      ),
    );
  }
}
