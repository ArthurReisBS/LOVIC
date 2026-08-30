import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/auth/gradient_blob_background.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/shared/lovic_logo.dart';
import '../../core/navigation/no_transition_route.dart';
import 'register_photo_screen.dart';

/// Register Screen 3: nome, sobrenome e data de nascimento.
class RegisterPersonalInfoScreen extends StatefulWidget {
  const RegisterPersonalInfoScreen({super.key});

  @override
  State<RegisterPersonalInfoScreen> createState() => _RegisterPersonalInfoScreenState();
}

class _RegisterPersonalInfoScreenState extends State<RegisterPersonalInfoScreen> {
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) {
      _dateController.text = '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBlobBackground(
        blobScale: 0.6,
        scattered: true,
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
                  'Fale um pouco sobre você',
                  style: AppTextStyles.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Text('Nome:', style: AppTextStyles.body),
                const SizedBox(height: 8),
                const AuthTextField(hintText: 'Digite seu nome...'),
                const SizedBox(height: 20),
                Text('Sobrenome:', style: AppTextStyles.body),
                const SizedBox(height: 8),
                const AuthTextField(hintText: 'Digite seu sobrenome...'),
                const SizedBox(height: 20),
                Text('Data de nascimento:', style: AppTextStyles.body),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  borderColor: AppColors.fieldBorderNeutral,
                  suffixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 18),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Avançar',
                  onPressed: () {
                    Navigator.of(context).push(noTransitionRoute(const RegisterPhotoScreen()));
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
