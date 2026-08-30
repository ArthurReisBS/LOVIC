import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/auth/gradient_blob_background.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/shared/lovic_logo.dart';
import '../../core/navigation/no_transition_route.dart';
import 'register_password_screen.dart';

/// Register Screen 4: avatar (placeholder) e username.
class RegisterPhotoScreen extends StatelessWidget {
  const RegisterPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBlobBackground(
        blobScale: 0.6,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const LovicLogo(fontSize: 56),
                const SizedBox(height: 48),
                Text(
                  'Vamos personalizar seu perfil',
                  style: AppTextStyles.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                const _AvatarPlaceholder(),
                const SizedBox(height: 12),
                Text('Escolha sua melhor foto', style: AppTextStyles.hint),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Username:', style: AppTextStyles.body),
                ),
                const SizedBox(height: 8),
                const AuthTextField(hintText: 'Digite um username...'),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Avançar',
                  onPressed: () {
                    Navigator.of(context).push(noTransitionRoute(const RegisterPasswordScreen()));
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

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.blobYellow),
            alignment: Alignment.center,
            child: Text('T', style: AppTextStyles.screenTitle.copyWith(fontSize: 48)),
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
