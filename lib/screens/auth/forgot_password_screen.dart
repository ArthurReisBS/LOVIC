import 'package:flutter/material.dart';
import '../../core/config/supabase_config.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/gradient_blob_background.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/shared/hover_scale.dart';
import '../../widgets/shared/lovic_logo.dart';

/// Esqueceu a senha, em duas etapas na mesma tela:
/// 1. pede o email e manda um código de 6 dígitos;
/// 2. a pessoa digita o código e a senha nova.
/// Ao terminar, volta ao login (devolvendo `true`) com um aviso de sucesso.
class ForgotPasswordScreen extends StatefulWidget {
  /// Email já digitado no login, para não digitar de novo.
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final _email = TextEditingController(text: widget.initialEmail);
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _sendCode() async {
    final email = _email.text.trim();
    if (!email.contains('@')) return _show('Digite um email válido.');
    if (!SupabaseConfig.isConfigured) {
      return _show('Conecte o banco (.env) para redefinir a senha.');
    }
    setState(() => _loading = true);
    try {
      await AuthService.sendPasswordReset(email);
      if (!mounted) return;
      setState(() => _codeSent = true);
      _show('Se esse email tiver conta, enviamos um código de 6 dígitos.');
    } on AuthFailure catch (e) {
      _show(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_code.text.trim().length < 6) {
      return _show('Digite o código de 6 dígitos do email.');
    }
    if (_password.text.length < 6) {
      return _show('A senha precisa de pelo menos 6 caracteres.');
    }
    if (_password.text != _confirm.text) {
      return _show('As senhas não são iguais.');
    }
    setState(() => _loading = true);
    try {
      await AuthService.resetPassword(
        email: _email.text,
        code: _code.text,
        newPassword: _password.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on AuthFailure catch (e) {
      _show(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: AppTextStyles.bodyBold),
  );

  List<Widget> _emailStep() => [
    Text(
      'Digite o email da sua conta e enviaremos um código para criar uma senha nova.',
      style: AppTextStyles.hint,
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: 28),
    _label('Email:'),
    AuthTextField(
      controller: _email,
      hintText: 'Digite seu email...',
      keyboardType: TextInputType.emailAddress,
    ),
    const SizedBox(height: 28),
    GradientButton(
      label: _loading ? 'Enviando...' : 'Enviar código',
      onPressed: _loading ? null : _sendCode,
    ),
  ];

  List<Widget> _codeStep() => [
    Text(
      'Enviamos um código para ${_email.text.trim()}. Digite-o abaixo com a senha nova.',
      style: AppTextStyles.hint,
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: 28),
    _label('Código:'),
    AuthTextField(
      controller: _code,
      hintText: '6 dígitos...',
      keyboardType: TextInputType.number,
    ),
    const SizedBox(height: 20),
    _label('Nova senha:'),
    AuthTextField(
      controller: _password,
      hintText: 'Digite a nova senha...',
      obscureText: true,
    ),
    const SizedBox(height: 20),
    _label('Confirme a senha:'),
    AuthTextField(
      controller: _confirm,
      hintText: 'Digite a mesma senha...',
      obscureText: true,
    ),
    const SizedBox(height: 28),
    GradientButton(
      label: _loading ? 'Salvando...' : 'Redefinir senha',
      onPressed: _loading ? null : _resetPassword,
    ),
    const SizedBox(height: 16),
    Center(
      child: HoverScale(
        child: GestureDetector(
          onTap: _loading ? null : _sendCode,
          child: Text('Reenviar código', style: AppTextStyles.linkOrange),
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBlobBackground(
        blobScale: .58,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left),
                  ),
                ),
                const Center(child: LovicLogo(fontSize: 38)),
                const SizedBox(height: 28),
                Center(
                  child: Text(
                    _codeSent ? 'Nova senha' : 'Esqueceu a senha?',
                    style: AppTextStyles.heading,
                  ),
                ),
                const SizedBox(height: 16),
                ...(_codeSent ? _codeStep() : _emailStep()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
