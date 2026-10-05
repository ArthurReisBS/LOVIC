/// Configuração única do ranking do Backend B.
///
/// 30 km e 80/20 são fallbacks documentados do alinhamento vigente.
/// Arthur pode injetar a configuração de produto do backend neste objeto.
class DiscoveryConfig {
  final double radiusKm;
  final double affinityWeight;
  final double proximityWeight;

  DiscoveryConfig({
    this.radiusKm = 30,
    this.affinityWeight = 0.8,
    this.proximityWeight = 0.2,
  }) {
    if (!radiusKm.isFinite || radiusKm <= 0) {
      throw ArgumentError.value(radiusKm, 'radiusKm');
    }
    if (!affinityWeight.isFinite ||
        !proximityWeight.isFinite ||
        affinityWeight < 0 ||
        proximityWeight < 0 ||
        (affinityWeight + proximityWeight - 1).abs() > 0.000001) {
      throw ArgumentError('Os pesos do ranking devem somar 1.');
    }
  }
}
