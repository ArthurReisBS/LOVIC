/// Stable codes for the frontend; wording belongs to the UI.
enum MatchReason {
  mutualLike('mutual_like'),
  highAffinity('high_affinity'),
  noMatch('no_match');

  const MatchReason(this.code);
  final String code;

  static MatchReason fromCode(String code) => values.firstWhere(
    (value) => value.code == code,
    orElse: () => throw FormatException('Motivo de match desconhecido: $code'),
  );
}

/// A successful like operation. Transport/auth errors remain failures.
class LikeResult {
  LikeResult({
    required this.deuMatch,
    required this.conversationId,
    required this.reason,
  }) {
    if (deuMatch &&
        (conversationId == null || conversationId!.trim().isEmpty)) {
      throw const FormatException('Match deve incluir o id da conversa.');
    }
    if (!deuMatch && conversationId != null) {
      throw const FormatException('Sem match não deve haver conversa.');
    }
    if (deuMatch == (reason == MatchReason.noMatch)) {
      throw const FormatException('Motivo incompatível com o resultado.');
    }
  }

  final bool deuMatch;
  final String? conversationId;
  final MatchReason reason;

  factory LikeResult.fromJson(Map<String, Object?> json) {
    final matched = json['deuMatch'];
    final conversation = json['conversationId'];
    final reason = json['reason'];
    if (matched is! bool ||
        (conversation != null && conversation is! String) ||
        reason is! String) {
      throw const FormatException('Resposta de curtir inválida.');
    }
    if (!json.containsKey('conversationId')) {
      throw const FormatException('Resposta deve incluir conversationId.');
    }
    return LikeResult(
      deuMatch: matched,
      conversationId: conversation as String?,
      reason: MatchReason.fromCode(reason),
    );
  }

  Map<String, Object?> toJson() => {
    'deuMatch': deuMatch,
    'conversationId': conversationId,
    'reason': reason.code,
  };
}
