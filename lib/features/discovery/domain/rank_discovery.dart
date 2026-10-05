import '../../affinity/domain/affinity_service.dart';
import '../../music_profile/domain/music_profile.dart';
import 'discovery_config.dart';
import 'discovery_profile.dart';

/// Regra pura. Proximidade = 100 * (1 - distância / raio), limitada a 0..100.
/// A distância recebida é preservada, sem arredondamento adicional no app.
class RankDiscovery {
  final DiscoveryConfig config;
  final AffinityService affinityService;

  RankDiscovery({
    DiscoveryConfig? config,
    this.affinityService = const AffinityService(),
  }) : config = config ?? DiscoveryConfig();

  DiscoveryProfile enrich(MusicProfile viewer, DiscoveryCandidate candidate) {
    final affinity = affinityService
        .calculate(viewer, candidate.musicProfile)
        .score;
    final proximity = (100 * (1 - candidate.distanceKm / config.radiusKm))
        .clamp(0.0, 100.0);
    return DiscoveryProfile(
      candidate: candidate,
      affinity: affinity,
      rankingScore:
          affinity * config.affinityWeight + proximity * config.proximityWeight,
    );
  }

  List<DiscoveryProfile> call({
    required MusicProfile viewer,
    required Iterable<DiscoveryCandidate> candidates,
  }) {
    final seen = <String>{};
    final profiles = candidates
        .where(
          (candidate) =>
              candidate.id != viewer.userId &&
              candidate.distanceKm <= config.radiusKm &&
              seen.add(candidate.id),
        )
        .map((candidate) => enrich(viewer, candidate))
        .toList();
    profiles.sort((a, b) {
      var comparison = b.rankingScore.compareTo(a.rankingScore);
      if (comparison != 0) return comparison;
      comparison = b.affinity.compareTo(a.affinity);
      if (comparison != 0) return comparison;
      comparison = a.distanceKm.compareTo(b.distanceKm);
      return comparison != 0 ? comparison : a.id.compareTo(b.id);
    });
    return List.unmodifiable(profiles);
  }
}
