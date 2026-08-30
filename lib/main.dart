import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const LovicApp());
}

class LovicApp extends StatelessWidget {
  const LovicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LOVIC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundStart,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
      ),
      home: const LoginScreen(),
    );
  }
}
