import '../../models/user_profile.dart';
import 'genre_colors.dart';

/// Gêneros que o usuário pode escolher no perfil. A cor de cada um vem da
/// posição na lista (os 5 primeiros mantêm as cores do Figma).
const List<String> availableGenres = [
  'Sertanejo',
  'Funk',
  'MPB',
  'Pop',
  'Rock',
  'Pagode',
  'Samba',
  'Forró',
  'Rap',
  'Hip Hop',
  'Reggae',
  'Eletrônica',
  'Indie',
  'Jazz',
  'Gospel',
  'Axé',
  'Blues',
  'Metal',
];

/// Gênero com a variante de cor definida pelo nome. Nomes fora da lista
/// também funcionam (cor calculada pelo texto).
ProfileGenre genreFromName(String name) {
  final i = availableGenres.indexOf(name);
  final index = i >= 0 ? i : name.codeUnits.fold<int>(0, (a, b) => a + b);
  return ProfileGenre(name, GenreVariant.values[index % GenreVariant.values.length]);
}
