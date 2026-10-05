import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/config/supabase_config.dart';
import '../../core/navigation/no_transition_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/music_genres.dart';
import '../../core/ui/em_breve.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/gradient_blob_background.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/home/genre_chip.dart';
import '../../widgets/shared/lovic_logo.dart';

/// Abre a edição de perfil e devolve `true` se algo foi salvo. Sem banco
/// (modo demonstração) só avisa que precisa do `.env`.
Future<bool> openEditProfile(BuildContext context) async {
  if (!SupabaseConfig.isConfigured) {
    mostrarEmBreve(context, 'Conecte o banco (.env) para editar o perfil.');
    return false;
  }
  final saved = await Navigator.of(
    context,
  ).push<bool>(noTransitionRoute(const EditProfileScreen()));
  return saved ?? false;
}

/// Edita foto, nome, bio, gêneros, informações pessoais e fotos do usuário
/// logado. O username não muda. Ao salvar com sucesso, fecha a tela
/// devolvendo `true`.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _bioMaxLength = 200;
  static const _maxPhotos = 6;
  static const _genderOptions = [
    'Mulher cisgênero',
    'Homem cisgênero',
    'Mulher trans',
    'Homem trans',
    'Não-binário',
    'Prefiro não dizer',
  ];
  static const _sexualityOptions = [
    'Heterossexual',
    'Homossexual',
    'Bissexual',
    'Pansexual',
    'Assexual',
    'Prefiro não dizer',
  ];

  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _bio = TextEditingController();
  final _height = TextEditingController();
  final _picker = ImagePicker();
  bool _loading = true;
  bool _saving = false;
  bool _uploading = false;
  String? _avatarUrl;
  String? _gender;
  String? _sexuality;
  final List<String> _genres = [];
  final List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _surname.dispose();
    _bio.dispose();
    _height.dispose();
    super.dispose();
  }

  /// Preenche os campos com o perfil atual.
  Future<void> _load() async {
    try {
      final profile = await AuthService.fetchMyProfile();
      if (!mounted) return;
      if (profile == null) {
        _showMessage('Não encontramos seu perfil.');
        Navigator.pop(context);
        return;
      }
      _name.text = profile.nome;
      _surname.text = profile.sobrenome ?? '';
      _bio.text = profile.bio ?? '';
      _height.text = profile.alturaCm?.toString() ?? '';
      _avatarUrl = profile.fotoUrl;
      _gender = profile.genero;
      _sexuality = profile.sexualidade;
      _genres.addAll(profile.generos);
      _photos.addAll(profile.fotos);
      setState(() => _loading = false);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Não foi possível carregar seu perfil.');
      Navigator.pop(context);
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return _showMessage('Digite seu nome.');
    final heightText = _height.text.trim();
    final height = heightText.isEmpty ? null : int.tryParse(heightText);
    if (heightText.isNotEmpty &&
        (height == null || height < 100 || height > 250)) {
      return _showMessage('Altura em centímetros, entre 100 e 250.');
    }
    setState(() => _saving = true);
    try {
      await AuthService.updateMyProfile(
        nome: _name.text,
        sobrenome: _surname.text,
        bio: _bio.text,
        fotoUrl: _avatarUrl,
        generos: _genres,
        genero: _gender,
        sexualidade: _sexuality,
        alturaCm: height,
        fotos: _photos,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(e.message);
    }
  }

  /// Escolhe uma imagem da galeria e envia para o Storage. Devolve a URL, ou
  /// null se cancelou ou falhou (a falha já foi avisada na tela).
  Future<String?> _pickAndUpload() async {
    if (_uploading) return null;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (file == null) return null;
      setState(() => _uploading = true);
      final bytes = await file.readAsBytes();
      final dot = file.name.lastIndexOf('.');
      final ext = dot < 0 ? 'jpg' : file.name.substring(dot + 1);
      return await AuthService.uploadPhoto(bytes, ext);
    } on AuthFailure catch (e) {
      if (mounted) {
        _showMessage(
          '${e.message}\n(Rodou o schema.sql atualizado no Supabase?)',
        );
      }
    } catch (_) {
      if (mounted) _showMessage('Não foi possível enviar a foto.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
    return null;
  }

  Future<void> _changeAvatar() async {
    final url = await _pickAndUpload();
    if (url != null && mounted) setState(() => _avatarUrl = url);
  }

  Future<void> _addPhoto() async {
    if (_photos.length >= _maxPhotos) {
      return _showMessage('Máximo de $_maxPhotos fotos.');
    }
    final url = await _pickAndUpload();
    if (url != null && mounted) setState(() => _photos.add(url));
  }

  void _toggleGenre(String name) => setState(() {
    _genres.contains(name) ? _genres.remove(name) : _genres.add(name);
  });

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: AppTextStyles.bodyBold),
  );

  Widget _avatar() {
    final name = _name.text.trim();
    final initial = name.isEmpty ? 'V' : name[0].toUpperCase();
    return Center(
      child: GestureDetector(
        onTap: _changeAvatar,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 54,
              backgroundColor: AppColors.blobYellow,
              backgroundImage: _avatarUrl != null
                  ? NetworkImage(_avatarUrl!)
                  : null,
              child: _avatarUrl == null
                  ? Text(
                      initial,
                      style: AppTextStyles.screenTitle.copyWith(
                        fontSize: 40,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.primary,
                child: _uploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.edit, size: 17, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genreSelector() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final name in availableGenres)
        GestureDetector(
          onTap: () => _toggleGenre(name),
          child: Opacity(
            opacity: _genres.contains(name) ? 1 : .35,
            child: GenreChip(label: name, variant: genreFromName(name).variant),
          ),
        ),
    ],
  );

  Widget _optionSelector(
    List<String> options,
    String? value,
    ValueChanged<String?> onChanged,
  ) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final o in options)
        ChoiceChip(
          label: Text(o),
          selected: value == o,
          onSelected: (on) => onChanged(on ? o : null),
        ),
    ],
  );

  Widget _photoGrid() => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      for (final url in _photos)
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                url,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: () => setState(() => _photos.remove(url)),
                child: const CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      if (_photos.length < _maxPhotos)
        GestureDetector(
          onTap: _addPhoto,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.add_a_photo_outlined),
          ),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBlobBackground(
        blobScale: .58,
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : SingleChildScrollView(
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
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Editar perfil',
                          style: AppTextStyles.heading,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _avatar(),
                      const SizedBox(height: 28),
                      _label('Nome:'),
                      AuthTextField(
                        controller: _name,
                        hintText: 'Digite seu nome...',
                      ),
                      const SizedBox(height: 24),
                      _label('Sobrenome:'),
                      AuthTextField(
                        controller: _surname,
                        hintText: 'Digite seu sobrenome...',
                      ),
                      const SizedBox(height: 24),
                      _label('Bio:'),
                      AuthTextField(
                        controller: _bio,
                        hintText: 'Conte o que você curte ouvir...',
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,
                        maxLength: _bioMaxLength,
                      ),
                      const SizedBox(height: 28),
                      _label('Gêneros musicais:'),
                      _genreSelector(),
                      const SizedBox(height: 28),
                      Text(
                        'Informações pessoais',
                        style: AppTextStyles.heading,
                      ),
                      const SizedBox(height: 16),
                      _label('Gênero:'),
                      _optionSelector(
                        _genderOptions,
                        _gender,
                        (v) => setState(() => _gender = v),
                      ),
                      const SizedBox(height: 20),
                      _label('Sexualidade:'),
                      _optionSelector(
                        _sexualityOptions,
                        _sexuality,
                        (v) => setState(() => _sexuality = v),
                      ),
                      const SizedBox(height: 20),
                      _label('Altura (cm):'),
                      AuthTextField(
                        controller: _height,
                        hintText: 'Ex.: 165',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 28),
                      Text('Fotos', style: AppTextStyles.heading),
                      const SizedBox(height: 16),
                      _photoGrid(),
                      const SizedBox(height: 32),
                      GradientButton(
                        label: _saving ? 'Salvando...' : 'Salvar',
                        onPressed: _saving ? null : _save,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
