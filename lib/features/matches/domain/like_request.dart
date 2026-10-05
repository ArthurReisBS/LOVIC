class LikeRequest {
  LikeRequest({
    required String actorUserId,
    required String targetUserId,
    required this.affinity,
  }) : actorUserId = actorUserId.trim(),
       targetUserId = targetUserId.trim() {
    if (this.actorUserId.isEmpty || this.targetUserId.isEmpty) {
      throw ArgumentError('Os ids de usuário devem estar preenchidos.');
    }
    if (this.actorUserId == this.targetUserId) {
      throw ArgumentError('Não é possível curtir a si mesmo.');
    }
    if (!affinity.isFinite || affinity < 0 || affinity > 100) {
      throw ArgumentError.value(
        affinity,
        'affinity',
        'Esperado score de 0 a 100.',
      );
    }
  }

  /// From Arthur's current authenticated session, not from a screen input.
  final String actorUserId;
  final String targetUserId;
  final double affinity;
}
