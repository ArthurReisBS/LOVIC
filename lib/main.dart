import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_colors.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }
  runApp(const ProviderScope(child: LovicApp()));
}

class LovicApp extends StatelessWidget {
  const LovicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LOVIC',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _LovicScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundStart,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      // Sessão salva de antes: entra direto, sem pedir login de novo.
      home: AuthService.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}

/// Deixa arrastar o feed e as listas com o mouse (Chrome/desktop), além do
/// toque. O padrão do Flutter não aceita arrastar com o mouse.
class _LovicScrollBehavior extends MaterialScrollBehavior {
  const _LovicScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}
