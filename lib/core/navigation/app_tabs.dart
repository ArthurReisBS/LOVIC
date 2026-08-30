import 'package:flutter/material.dart';
import 'no_transition_route.dart';
import '../../screens/home/conversations_screen.dart';
import '../../screens/home/home_screen.dart';
// import '../../screens/home/my_profile_screen.dart'; // desativado pra apresentação — descomente pra reativar o ícone de perfil
import '../../screens/home/profile_card_screen.dart';
import '../../screens/home/settings_screen.dart';

/// Navega para a tela correspondente ao índice tocado na [AppBottomNav].
///
/// Índices: 0 = perfil, 1 = curtidas/descobrir, 2 = home, 3 = chat,
/// 4 = configurações. Centralizado aqui pra não repetir o mesmo switch em
/// cada tela que usa a barra inferior.
void goToTab(BuildContext context, int index) {
  // Ícone "Meu Perfil" (índice 0) desativado pra apresentação: fica visível
  // na barra, mas não navega pra lugar nenhum. Pra reativar depois, descomente
  // o import de MyProfileScreen acima, descomente o case "0 => ..." abaixo,
  // e apague este "if".
  if (index == 0) return;

  final Widget screen = switch (index) {
    // 0 => const MyProfileScreen(),
    1 => const ProfileCardScreen(),
    2 => const HomeScreen(),
    3 => const ConversationsScreen(),
    _ => const SettingsScreen(),
  };
  Navigator.of(context).pushReplacement(noTransitionRoute(screen));
}
