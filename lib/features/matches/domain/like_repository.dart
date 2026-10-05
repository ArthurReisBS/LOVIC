import 'like_result.dart';

enum LikeFailureCode {
  sessionExpired,
  invalidRequest,
  invalidResponse,
  unavailable,
}

/// Erro estável para a UI; nunca expõe exceções ou payloads do Supabase.
class LikeFailure implements Exception {
  const LikeFailure(this.code);

  final LikeFailureCode code;

  String get message => switch (code) {
    LikeFailureCode.sessionExpired =>
      'Sua sessão expirou. Entre novamente para curtir.',
    LikeFailureCode.invalidRequest => 'Não foi possível enviar esta curtida.',
    LikeFailureCode.invalidResponse =>
      'O resultado da curtida não pôde ser confirmado.',
    LikeFailureCode.unavailable =>
      'Não foi possível curtir agora. Tente novamente.',
  };

  @override
  String toString() => 'LikeFailure(${code.name})';
}

abstract interface class LikeRepository {
  Future<LikeResult> like({
    required String targetUserId,
    required double affinity,
  });
}
