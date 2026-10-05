/// Optional local preview of the configured high-affinity condition.
/// This never creates a match: the backend's result remains authoritative.
class MatchPolicy {
  MatchPolicy({required this.highAffinityThreshold}) {
    if (!highAffinityThreshold.isFinite ||
        highAffinityThreshold < 0 ||
        highAffinityThreshold > 100) {
      throw ArgumentError.value(
        highAffinityThreshold,
        'highAffinityThreshold',
        'Esperado limiar de 0 a 100.',
      );
    }
  }

  /// Inject the product/Backend A setting. No numeric fallback is agreed in
  /// PLANO_LEO or the frontend/backend PDF, so none is invented here.
  final double highAffinityThreshold;

  bool isHighAffinity(double affinity) {
    if (!affinity.isFinite || affinity < 0 || affinity > 100) {
      throw ArgumentError.value(
        affinity,
        'affinity',
        'Esperado score de 0 a 100.',
      );
    }
    return affinity >= highAffinityThreshold;
  }
}
