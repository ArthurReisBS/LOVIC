import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/auth/gradient_blob_background.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/auth/otp_input_box.dart';
import '../../widgets/shared/lovic_logo.dart';
import '../../widgets/shared/hover_scale.dart';
import '../../core/navigation/no_transition_route.dart';
import 'register_personal_info_screen.dart';

/// Register Screen 2: código de verificação enviado por email.
class RegisterOtpScreen extends StatefulWidget {
  const RegisterOtpScreen({super.key});

  static const String mockEmail = 'teste@email.com';

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

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
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                    children: [
                      const TextSpan(text: 'Digite o código que enviamos para\no email: '),
                      TextSpan(
                        text: RegisterOtpScreen.mockEmail,
                        style: AppTextStyles.bodyBold,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => OtpInputBox(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      onChanged: (value) => _onDigitChanged(index, value),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                HoverScale(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Código reenviado!')),
                      );
                    },
                    child: Text('Reenviar código', style: AppTextStyles.linkOrange),
                  ),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Confirmar',
                  onPressed: () {
                    Navigator.of(context).push(noTransitionRoute(const RegisterPersonalInfoScreen()));
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
