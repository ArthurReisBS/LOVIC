import 'package:flutter/material.dart';
import '../core/theme/genre_colors.dart';
import '../core/theme/music_genres.dart';
import 'user_profile.dart';

/// Funções puras que transformam uma linha de `public.profiles` em
/// [UserProfile]. Não dependem do Supabase, então são testáveis sozinhas.

const String bioPadrao = 'Ainda sem bio.';

// MOCK: gêneros de exemplo até a integração com o Spotify (CP06).
const List<ProfileGenre> _generosDeExemplo = [
  ProfileGenre('Sertanejo', GenreVariant.v1),
  ProfileGenre('Funk', GenreVariant.v2),
  ProfileGenre('MPB', GenreVariant.v3),
  ProfileGenre('Pop', GenreVariant.v4),
  ProfileGenre('Rock', GenreVariant.v5),
];

// MOCK: cores de exemplo no lugar da foto até o upload de fotos (CP06).
const List<Color> _coresDeExemplo = [
  Color(0xFF8C6A5D),
  Color(0xFF5D7A8C),
  Color(0xFF8C5D7A),
  Color(0xFF6A8C5D),
  Color(0xFF7A5D8C),
];

String? nullIfBlank(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();

/// Hash simples e estável (o `hashCode` do Dart pode mudar entre execuções).
int _hashEstavel(String texto) {
  var hash = 17;
  for (final unidade in texto.codeUnits) {
    hash = (hash * 31 + unidade) & 0x7fffffff;
  }
  return hash;
}

/// Idade em anos completos em [hoje], ou null se não houver data (ou se ela
/// estiver no futuro).
int? calcularIdade(DateTime? nascimento, DateTime hoje) {
  if (nascimento == null) return null;
  var idade = hoje.year - nascimento.year;
  final fezAniversario =
      hoje.month > nascimento.month ||
      (hoje.month == nascimento.month && hoje.day >= nascimento.day);
  if (!fezAniversario) idade--;
  return idade < 0 ? null : idade;
}

/// 2 ou 3 gêneros de exemplo, sempre os mesmos para o mesmo [id].
List<ProfileGenre> generosDeExemplo(String id) {
  final hash = _hashEstavel(id);
  final quantidade = 2 + hash % 2;
  final inicio = hash % _generosDeExemplo.length;
  return [
    for (var i = 0; i < quantidade; i++)
      _generosDeExemplo[(inicio + i) % _generosDeExemplo.length],
  ];
}

/// Cor de exemplo, sempre a mesma para o mesmo [id].
Color corDeExemplo(String id) =>
    _coresDeExemplo[_hashEstavel(id) % _coresDeExemplo.length];

/// Converte uma linha do banco (`id, nome, sobrenome, username, bio,
/// data_nascimento`) em [UserProfile]. [hoje] existe para os testes.
UserProfile perfilDeLinha(Map<String, dynamic> row, {DateTime? hoje}) {
  final id = row['id'] as String;
  final nome = (row['nome'] as String? ?? '').trim();
  final sobrenome = (row['sobrenome'] as String? ?? '').trim();
  final bio = (row['bio'] as String? ?? '').trim();
  final nascimento = DateTime.tryParse(row['data_nascimento'] as String? ?? '');
  final username = row['username'] as String?;
  final generos = (row['generos'] as List?)?.whereType<String>().toList();
  final fotos = (row['fotos'] as List?)?.whereType<String>().toList() ?? [];
  final nomeCompleto = [nome, sobrenome].where((t) => t.isNotEmpty).join(' ');
  return UserProfile(
    id: id,
    username: username,
    age: calcularIdade(nascimento, hoje ?? DateTime.now()),
    // O nome nunca fica vazio: as telas usam a primeira letra dele.
    name: nomeCompleto.isNotEmpty ? nomeCompleto : (username ?? 'Sem nome'),
    bio: bio.isEmpty ? bioPadrao : bio,
    // Sem gêneros escolhidos (coluna ausente/vazia) cai nos de exemplo.
    genres: (generos == null || generos.isEmpty)
        ? generosDeExemplo(id)
        : generos.map(genreFromName).toList(),
    photoColor: corDeExemplo(id),
    photoUrl: nullIfBlank(row['foto_url'] as String?),
    photos: fotos,
    gender: nullIfBlank(row['genero'] as String?),
    sexuality: nullIfBlank(row['sexualidade'] as String?),
    heightCm: row['altura_cm'] as int?,
  );
}
