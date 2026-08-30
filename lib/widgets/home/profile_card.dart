import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_profile.dart';
import '../shared/hover_scale.dart';
import 'genre_chip.dart';

/// Gradiente laranja→amarelo usado no botão "Ver perfil", no botão de
/// localização e no texto do botão "Mandar mensagem".
const List<Color> _actionGradient = [Color(0xFFFF9A42), Color(0xFFFFE682)];

/// Gradiente laranja→amarelo-claro usado no texto do botão "Mandar mensagem".
const List<Color> _messageTextGradient = [Color(0xFFFF9A42), Color(0xFFFFDB97)];

/// Card de perfil em tela cheia: foto grande, bolhas decorativas, chips de
/// gênero, nome, bio e ações (ver perfil, mandar mensagem, ver localização).
///
/// Segurar a foto (tocar e manter pressionado) esconde o texto/botões por
/// cima pra ver a imagem por inteiro, soltando volta ao normal.
class ProfileCard extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback? onViewProfile;
  final VoidCallback? onMessage;
  final VoidCallback? onLocation;

  const ProfileCard({
    super.key,
    required this.profile,
    this.onViewProfile,
    this.onMessage,
    this.onLocation,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  bool _holding = false;

  void _setHolding(bool value) {
    if (_holding != value) setState(() => _holding = value);
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return GestureDetector(
      onTapDown: (_) => _setHolding(true),
      onTapUp: (_) => _setHolding(false),
      onTapCancel: () => _setHolding(false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Foto real quando disponível; senão, placeholder de cor sólida.
            profile.photoAsset != null
                ? Image.asset(profile.photoAsset!, fit: BoxFit.cover)
                : Container(color: profile.photoColor),
            AnimatedOpacity(
              opacity: _holding ? 0 : 1,
              duration: const Duration(milliseconds: 150),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0),
                            Colors.black.withValues(alpha: 0.85),
                          ],
                          stops: const [0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Bolhas decorativas desfocadas, por cima do degradê escuro
                  // (mesmo estilo das telas de auth): vermelha vazando pela
                  // esquerda, verde vazando pela direita.
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(-1.3, -0.15),
                      child: _blob(80, AppColors.blobRed),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(1.35, 0.6),
                      child: _blob(70, AppColors.blobGreen),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.genres
                              .map((g) => GenreChip(label: g.name, variant: g.variant))
                              .toList(),
                        ),
                        const SizedBox(height: 14),
                        Text(profile.name, style: AppTextStyles.heading),
                        const SizedBox(height: 6),
                        Text(
                          profile.bio,
                          style: AppTextStyles.body.copyWith(color: Colors.white70),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: HoverScale(
                                scale: 1.04,
                                child: _GradientActionButton(
                                  label: 'Ver perfil',
                                  onPressed: widget.onViewProfile ?? () {},
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: HoverScale(
                                scale: 1.04,
                                child: _MessageButton(
                                  label: 'Mandar mensagem',
                                  onPressed: widget.onMessage ?? () {},
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _LocationButton(onTap: widget.onLocation),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.65)),
      ),
    );
  }
}

/// Botão pill com fundo em gradiente laranja→amarelo (usado em "Ver perfil").
class _GradientActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GradientActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: _actionGradient),
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: AppTextStyles.bodyBold.copyWith(fontSize: 12), maxLines: 1),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão pill com fundo branco (#FEFEFE) e texto em gradiente laranja→amarelo
/// claro (usado em "Mandar mensagem"). O texto encolhe com [FittedBox] pra
/// nunca quebrar/vazar do botão em telas estreitas.
class _MessageButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _MessageButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.textPrimary,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(colors: _messageTextGradient).createShader(bounds),
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppTextStyles.bodyBold.copyWith(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _LocationButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return HoverScale(
      scale: 1.12,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: _actionGradient),
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap ?? () {},
            child: const Padding(
              padding: EdgeInsets.all(11),
              child: Icon(Icons.location_on, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}
