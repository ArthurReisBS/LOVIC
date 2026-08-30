import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/auth/gradient_blob_background.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/shared/lovic_logo.dart';
import '../../core/navigation/no_transition_route.dart';
import '../home/home_screen.dart';

/// Register Screen 5: senha e confirmação, último passo do cadastro.
class RegisterPasswordScreen extends StatelessWidget {
  const RegisterPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBlobBackground(
        blobScale: 0.6,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Center(child: LovicLogo(fontSize: 56)),
                const SizedBox(height: 48),
                Text(
                  'Agora vamos manter sua conta segura',
                  style: AppTextStyles.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Text('Senha:', style: AppTextStyles.body),
                const SizedBox(height: 8),
                const AuthTextField(hintText: 'Digite uma senha forte...', obscureText: true),
                const SizedBox(height: 20),
                Text('Confirme a senha:', style: AppTextStyles.body),
                const SizedBox(height: 8),
                const AuthTextField(hintText: 'Digite a mesma senha...', obscureText: true),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Criar conta',
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      noTransitionRoute(const HomeScreen()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
