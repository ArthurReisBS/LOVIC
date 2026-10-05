import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../models/register_draft.dart';
import '../models/user_profile.dart';
import '../models/user_profile_mapper.dart';

/// Erro de cadastro/login já com a mensagem pronta para mostrar na tela.
class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);

  @override
  String toString() => message;
}

/// Perfil do usuário logado, como está salvo em `public.profiles`.
class MyProfile {
  final String nome;
  final String? sobrenome;
  final String username;
  final String? bio;
  final String? fotoUrl;
  final List<String> generos;
  final String? genero;
  final String? sexualidade;
  final int? alturaCm;
  final List<String> fotos;

  const MyProfile({
    required this.nome,
    required this.sobrenome,
    required this.username,
    required this.bio,
    this.fotoUrl,
    this.generos = const [],
    this.genero,
    this.sexualidade,
    this.alturaCm,
    this.fotos = const [],
  });

  String get nomeCompleto =>
      [nome, if (sobrenome != null) sobrenome].join(' ').trim();

  factory MyProfile.fromRow(Map<String, dynamic> row) => MyProfile(
    nome: row['nome'] as String? ?? '',
    sobrenome: row['sobrenome'] as String?,
    username: row['username'] as String,
    bio: row['bio'] as String?,
    fotoUrl: row['foto_url'] as String?,
    generos: (row['generos'] as List?)?.whereType<String>().toList() ?? [],
    genero: row['genero'] as String?,
    sexualidade: row['sexualidade'] as String?,
    alturaCm: row['altura_cm'] as int?,
    fotos: (row['fotos'] as List?)?.whereType<String>().toList() ?? [],
  );
}

/// Texto sem espaços nas pontas, ou null se ficar vazio.
String? nullIfEmpty(String? value) {
  final text = value?.trim();
  return (text == null || text.isEmpty) ? null : text;
}

/// Cadastro, login e perfil no Supabase (Backend A do CP05).
///
/// Sem `.env` ([SupabaseConfig.isConfigured] falso) nada aqui é chamado: as
/// telas seguem em modo demonstração.
class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  static bool get isLoggedIn =>
      SupabaseConfig.isConfigured && _client.auth.currentSession != null;

  /// Cria a conta. O perfil em `public.profiles` é criado pelo trigger
  /// `handle_new_user` a partir dos dados mandados em `data`.
  static Future<void> signUp(RegisterDraft draft, String password) async {
    final disponivel = await _guard(
      () => _client.rpc(
        'username_disponivel',
        params: {'nome_usuario': draft.username},
      ),
    );
    if (disponivel == false) {
      throw const AuthFailure(
        'Esse username já está em uso. Volte e escolha outro.',
      );
    }

    final response = await _guard(
      () => _client.auth.signUp(
        email: draft.email,
        password: password,
        data: {
          'nome': draft.nome,
          'sobrenome': draft.sobrenome,
          'data_nascimento': draft.dataNascimento,
          'username': draft.username,
        },
      ),
    );
    // Com "Confirm email" ligado no Supabase o signUp não devolve sessão.
    if (response.session == null) {
      throw const AuthFailure(
        'Conta criada, mas falta confirmar o email. Desligue "Confirm email" no Supabase para o protótipo.',
      );
    }
  }

  static Future<void> signIn(String email, String password) async {
    await _guard(
      () => _client.auth.signInWithPassword(email: email, password: password),
    );
  }

  static Future<void> signOut() => _client.auth.signOut();

  /// Perfil de quem está logado, ou null em modo demonstração.
  static Future<MyProfile?> fetchMyProfile() async {
    if (!isLoggedIn) return null;
    final row = await _guard(
      () => _client
          .from('profiles')
          .select(
            'nome, sobrenome, username, bio, foto_url, generos, genero, '
            'sexualidade, altura_cm, fotos',
          )
          .eq('id', _client.auth.currentUser!.id)
          .maybeSingle(),
    );
    return row == null ? null : MyProfile.fromRow(row);
  }

  /// Outras pessoas cadastradas, das mais novas para as mais antigas. Sem
  /// banco (modo demonstração) devolve os perfis de exemplo.
  static Future<List<UserProfile>> fetchOtherProfiles({int limit = 50}) async {
    if (!SupabaseConfig.isConfigured) return mockProfiles;
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthFailure('Sessão expirada. Entre de novo.');
    final rows = await _guard(
      () => _client
          .from('profiles')
          .select('id, nome, sobrenome, username, bio, data_nascimento, foto_url, '
              'generos, genero, sexualidade, altura_cm, fotos')
          .neq('id', user.id)
          .order('criado_em', ascending: false)
          .limit(limit),
    );
    return rows.map(perfilDeLinha).toList();
  }

  /// Atualiza o perfil de quem está logado. O username não muda (é único e
  /// funciona como identificador). Campos de texto vazios viram null.
  static Future<void> updateMyProfile({
    required String nome,
    String? sobrenome,
    String? bio,
    String? fotoUrl,
    List<String> generos = const [],
    String? genero,
    String? sexualidade,
    int? alturaCm,
    List<String> fotos = const [],
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthFailure('Sessão expirada. Entre de novo.');
    }
    await _guard(
      () => _client
          .from('profiles')
          .update({
            'nome': nome.trim(),
            'sobrenome': nullIfEmpty(sobrenome),
            'bio': nullIfEmpty(bio),
            'foto_url': fotoUrl,
            'generos': generos,
            'genero': nullIfEmpty(genero),
            'sexualidade': nullIfEmpty(sexualidade),
            'altura_cm': alturaCm,
            'fotos': fotos,
          })
          .eq('id', user.id),
    );
  }

  /// Envia uma imagem para o bucket `fotos` (pasta do próprio usuário) e
  /// devolve a URL pública.
  static Future<String> uploadPhoto(Uint8List bytes, String extension) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthFailure('Sessão expirada. Entre de novo.');
    }
    final ext = extension.isEmpty ? 'jpg' : extension.toLowerCase();
    final path = '${user.id}/${DateTime.now().microsecondsSinceEpoch}.$ext';
    await _guard(
      () => _client.storage
          .from('fotos')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: 'image/${ext == 'jpg' ? 'jpeg' : ext}'),
          ),
    );
    return _client.storage.from('fotos').getPublicUrl(path);
  }

  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AuthException catch (e) {
      throw AuthFailure(_authMessage(e));
    } on PostgrestException catch (e) {
      throw AuthFailure('Erro no banco: ${e.message}');
    } catch (_) {
      throw const AuthFailure('Sem conexão com o servidor. Tente de novo.');
    }
  }

  static String _authMessage(AuthException e) => switch (e.code) {
    'invalid_credentials' => 'Email ou senha incorretos.',
    'user_already_exists' ||
    'email_exists' => 'Esse email já tem conta. Faça login.',
    'weak_password' => 'Senha fraca: use pelo menos 6 caracteres.',
    'email_address_invalid' || 'validation_failed' => 'Email inválido.',
    'email_not_confirmed' => 'Confirme o email antes de entrar.',
    'over_email_send_rate_limit' || 'over_request_rate_limit' =>
      'Muitas tentativas. Espere um pouco e tente de novo.',
    _ => e.message,
  };
}
