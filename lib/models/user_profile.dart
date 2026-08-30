import 'package:flutter/material.dart';
import '../core/theme/genre_colors.dart';

/// Um gênero musical associado a uma variante de cor do design system.
class ProfileGenre {
  final String name;
  final GenreVariant variant;

  const ProfileGenre(this.name, this.variant);
}

/// Representa um perfil de usuário exibido no app.
///
/// [photoColor] é usado como placeholder visual da foto quando não há
/// [photoAsset] definido, já que ainda não existe integração real com
/// upload/armazenamento de imagens.
class UserProfile {
  final String name;
  final String bio;
  final List<ProfileGenre> genres;
  final Color photoColor;
  final String? photoAsset;

  const UserProfile({
    required this.name,
    required this.bio,
    required this.genres,
    required this.photoColor,
    this.photoAsset,
  });
}

/// Perfis mockados para testar as telas enquanto não há backend.
final List<UserProfile> mockProfiles = [
  const UserProfile(
    name: 'Carla Silva',
    bio: 'Lorem ipsum é um texto modelo da indústria tipográfica e de '
        'impressão. O Lorem Ipsum tem vindo a ser o texto padrão usado por '
        'estas indústrias desde o ano de 1500.',
    genres: [
      ProfileGenre('Sertanejo', GenreVariant.v1),
      ProfileGenre('Funk', GenreVariant.v2),
      ProfileGenre('MPB', GenreVariant.v3),
    ],
    photoColor: Color(0xFF8C6A5D),
    photoAsset: 'assets/images/carla_silva.png',
  ),
  const UserProfile(
    name: 'Diego Alves',
    bio: 'Guitarrista nas horas vagas, apaixonado por rock e indie. Se '
        'você curte um show pequeno e cervejinha depois, bora trocar '
        'referência musical.',
    genres: [
      ProfileGenre('Rock', GenreVariant.v5),
      ProfileGenre('Pop', GenreVariant.v4),
    ],
    photoColor: Color(0xFF5D7A8C),
  ),
  const UserProfile(
    name: 'Bia Ferreira',
    bio: 'Funk no talo de manhã, MPB pra relaxar à noite. Adoro conhecer '
        'gente nova e trocar indicação de música. E você, curte o quê?',
    genres: [
      ProfileGenre('Funk', GenreVariant.v2),
      ProfileGenre('MPB', GenreVariant.v3),
    ],
    photoColor: Color(0xFF8C5D7A),
  ),
];
