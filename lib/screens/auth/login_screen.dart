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
import '../../core/navigation/no_transition_route.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                      Text('Bem-vindo!', style: AppTextStyles.heading, textAlign: TextAlign.center),
                      Column(
                        children: [
                          const AuthTextField(hintText: 'Digite seu email ou username...'),
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
                            label: 'Login com Google',
                            backgroundColor: AppColors.socialButtonLight,
                            textColor: AppColors.textSecondary,
                            onPressed: () => _goHome(context),
                          ),
                          const SizedBox(height: 16),
                          SocialLoginButton(
                            icon: const Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: FaIcon(FontAwesomeIcons.spotify, color: AppColors.spotifyGreen, size: 22),
                            ),
                            label: 'Login com Spotify',
                            backgroundColor: AppColors.socialButtonSpotify,
                            textColor: AppColors.textPrimary,
                            onPressed: () => _goHome(context),
                          ),
                        ],
                      ),
                      HoverScale(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(noTransitionRoute(const RegisterScreen()));
                          },
                          child: Text('Criar uma conta', style: AppTextStyles.linkOrange),
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

  void _goHome(BuildContext context) {
    Navigator.of(context).pushReplacement(noTransitionRoute(const HomeScreen()));
  }
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
