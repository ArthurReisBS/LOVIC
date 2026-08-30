import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/auth/gradient_blob_background.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/social_login_button.dart';
import '../../widgets/shared/lovic_logo.dart';
import '../../widgets/shared/hover_scale.dart';
// import 'register_otp_screen.dart'; // desativado pra apresentação — descomente pra reativar o fluxo de cadastro

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBlobBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const LovicLogo(fontSize: 64),
                      Text('Novo aqui?', style: AppTextStyles.heading, textAlign: TextAlign.center),
                      Column(
                        children: [
                          const AuthTextField(hintText: 'Digite seu melhor email...'),
                          const SizedBox(height: 28),
                          const _OrDivider(),
                        ],
                      ),
                      Column(
                        children: [
                          SocialLoginButton(
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: SvgPicture.asset('assets/images/google_logo.svg'),
                              ),
                            ),
                            label: 'Criar com Google',
                            backgroundColor: AppColors.socialButtonLight,
                            textColor: AppColors.textSecondary,
                            // onPressed: () => _goToOtp(context), // desativado pra apresentação
                          ),
                          const SizedBox(height: 16),
                          SocialLoginButton(
                            icon: const Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: FaIcon(FontAwesomeIcons.spotify, color: AppColors.spotifyGreen, size: 22),
                            ),
                            label: 'Criar com Spotify',
                            backgroundColor: AppColors.socialButtonSpotify,
                            textColor: AppColors.textPrimary,
                            // onPressed: () => _goToOtp(context), // desativado pra apresentação
                          ),
                        ],
                      ),
                      HoverScale(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text('Já tem uma conta?', style: AppTextStyles.linkOrange),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Desativado pra apresentação, junto com os "onPressed" acima e o import
  // de RegisterOtpScreen. Pra reativar o fluxo de cadastro depois, descomente
  // os três.
  // void _goToOtp(BuildContext context) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(builder: (_) => const RegisterOtpScreen()),
  //   );
  // }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.textMuted.withValues(alpha: 0.4))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou', style: AppTextStyles.hint),
        ),
        Expanded(child: Divider(color: AppColors.textMuted.withValues(alpha: 0.4))),
      ],
    );
  }
}
