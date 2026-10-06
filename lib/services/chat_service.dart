import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../models/user_profile.dart';
import '../models/user_profile_mapper.dart';
import 'auth_service.dart';

/// Uma mensagem de `public.mensagens`.
class ChatMessage {
  final int? id;
  final String text;
  final bool isMine;
  final DateTime sentAt;

  const ChatMessage({
    this.id,
    required this.text,
    required this.isMine,
    required this.sentAt,
  });

  factory ChatMessage.fromRow(Map<String, dynamic> row, String myId) =>
      ChatMessage(
        id: row['id'] as int,
        text: row['texto'] as String,
        isMine: row['remetente_id'] == myId,
        sentAt: DateTime.parse(row['criado_em'] as String).toLocal(),
      );
}

/// Uma conversa na tela de Chats: com quem e a última mensagem.
class ChatConversation {
  final UserProfile profile;
  final ChatMessage lastMessage;

  const ChatConversation({required this.profile, required this.lastMessage});
}

/// Chat entre o usuário logado e outra pessoa, salvo no Supabase.
///
/// Sem `.env`, ou com um perfil de exemplo (sem `id`), [canPersist] é falso e
/// a tela mantém as mensagens só na memória.
class ChatService {
  static SupabaseClient get _client => Supabase.instance.client;

  static bool canPersist(String? otherUserId) =>
      otherUserId != null && AuthService.isLoggedIn;

  /// Mesma chave da coluna gerada `conversa` no banco: "menor:maior".
  static String conversationKey(String a, String b) =>
      a.compareTo(b) < 0 ? '$a:$b' : '$b:$a';

  static String get _myId {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthFailure('Sessão expirada. Entre de novo.');
    return user.id;
  }

  /// Mensagens da conversa, da mais antiga para a mais nova.
  static Future<List<ChatMessage>> fetchMessages(String otherUserId) async {
    final myId = _myId;
    final rows = await _guard(
      () => _client
          .from('mensagens')
          .select('id, remetente_id, texto, criado_em')
          .eq('conversa', conversationKey(myId, otherUserId))
          .order('criado_em'),
    );
    return rows.map((row) => ChatMessage.fromRow(row, myId)).toList();
  }

  /// Conversas de quem está logado, da mais recente para a mais antiga. Em
  /// modo demonstração devolve lista vazia.
  static Future<List<ChatConversation>> fetchConversations({
    int limit = 500,
  }) async {
    if (!AuthService.isLoggedIn) return [];
    final myId = _myId;
    // O RLS já devolve só as mensagens em que eu sou remetente ou destinatário.
    final rows = await _guard(
      () => _client
          .from('mensagens')
          .select('id, remetente_id, destinatario_id, texto, criado_em')
          .order('criado_em', ascending: false)
          .limit(limit),
    );
    final latestByOther = <String, ChatMessage>{};
    for (final row in rows) {
      final otherId = row['remetente_id'] == myId
          ? row['destinatario_id'] as String
          : row['remetente_id'] as String;
      latestByOther.putIfAbsent(otherId, () => ChatMessage.fromRow(row, myId));
    }
    if (latestByOther.isEmpty) return [];

    final profiles = await _guard(
      () => _client
          .from('profiles')
          .select('id, nome, sobrenome, username, bio, data_nascimento, foto_url, '
              'generos, genero, sexualidade, altura_cm, fotos')
          .inFilter('id', latestByOther.keys.toList()),
    );
    final profileById = {
      for (final row in profiles) row['id'] as String: perfilDeLinha(row),
    };
    return [
      for (final MapEntry(key: otherId, value: message) in latestByOther.entries)
        if (profileById[otherId] case final profile?)
          ChatConversation(profile: profile, lastMessage: message),
    ];
  }

  /// Grava a mensagem e devolve como ficou no banco (com `id` e horário).
  static Future<ChatMessage> sendMessage(String otherUserId, String text) async {
    final myId = _myId;
    final row = await _guard(
      () => _client
          .from('mensagens')
          .insert({
            'remetente_id': myId,
            'destinatario_id': otherUserId,
            'texto': text,
          })
          .select('id, remetente_id, texto, criado_em')
          .single(),
    );
    return ChatMessage.fromRow(row, myId);
  }

  /// Avisa cada mensagem nova da conversa, de qualquer um dos lados.
  /// Chame [stopListening] com o canal devolvido ao sair da tela.
  static RealtimeChannel listen(
    String otherUserId,
    void Function(ChatMessage message) onMessage,
  ) {
    final myId = _myId;
    final key = conversationKey(myId, otherUserId);
    return _client
        .channel('mensagens:$key')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'mensagens',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversa',
            value: key,
          ),
          callback: (payload) =>
              onMessage(ChatMessage.fromRow(payload.newRecord, myId)),
        )
        .subscribe();
  }

  static Future<void> stopListening(RealtimeChannel channel) async {
    if (!SupabaseConfig.isConfigured) return;
    await _client.removeChannel(channel);
  }

  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PostgrestException catch (e) {
      throw AuthFailure('Erro no banco: ${e.message}');
    } catch (_) {
      throw const AuthFailure('Sem conexão com o servidor. Tente de novo.');
    }
  }
}
