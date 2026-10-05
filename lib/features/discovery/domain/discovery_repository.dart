import '../../music_profile/domain/music_profile.dart';
import 'discovery_profile.dart';
import 'rank_discovery.dart';

enum DiscoveryError {
  network,
  sessionExpired,
  locationRequired,
  notFound,
  unexpected,
}

/// O adaptador Supabase do Arthur deve mapear erros técnicos para estes códigos.
class DiscoveryDataException implements Exception {
  final DiscoveryError code;
  const DiscoveryDataException(this.code);
}

/// Porta do Backend A. Elegibilidade/RLS e distância arredondada ficam no banco.
abstract interface class DiscoveryDataSource {
  Future<List<DiscoveryCandidate>> fetchNearby({required double radiusKm});
  Future<DiscoveryCandidate?> fetchProfile(String userId);
}

class DiscoveryResult {
  final List<DiscoveryProfile> profiles;
  final double radiusKm;
  final DiscoveryError? error;

  DiscoveryResult.success(Iterable<DiscoveryProfile> profiles, this.radiusKm)
    : profiles = List.unmodifiable(profiles),
      error = null;
  DiscoveryResult.failure(DiscoveryError failure, this.radiusKm)
    : profiles = const [],
      error = failure;

  bool get isEmpty => error == null && profiles.isEmpty;
  bool get isSuccess => error == null;
}

class DiscoveryProfileResult {
  final DiscoveryProfile? profile;
  final DiscoveryError? error;

  const DiscoveryProfileResult.success(DiscoveryProfile this.profile)
    : error = null;
  const DiscoveryProfileResult.failure(DiscoveryError this.error)
    : profile = null;
}

/// Isabelle fornece o perfil musical próprio salvo pela integração Spotify.
/// Nenhum mock é usado como fallback de falha do backend.
class DiscoveryRepository {
  final DiscoveryDataSource dataSource;
  final RankDiscovery ranking;

  DiscoveryRepository({required this.dataSource, RankDiscovery? ranking})
    : ranking = ranking ?? RankDiscovery();

  Future<DiscoveryResult> discover({required MusicProfile viewer}) async {
    try {
      final candidates = await dataSource.fetchNearby(
        radiusKm: ranking.config.radiusKm,
      );
      return DiscoveryResult.success(
        ranking(viewer: viewer, candidates: candidates),
        ranking.config.radiusKm,
      );
    } on DiscoveryDataException catch (error) {
      return DiscoveryResult.failure(error.code, ranking.config.radiusKm);
    } catch (_) {
      return DiscoveryResult.failure(
        DiscoveryError.unexpected,
        ranking.config.radiusKm,
      );
    }
  }

  Future<DiscoveryProfileResult> getProfile({
    required MusicProfile viewer,
    required String userId,
  }) async {
    try {
      final candidate = await dataSource.fetchProfile(userId);
      if (candidate == null) {
        return const DiscoveryProfileResult.failure(DiscoveryError.notFound);
      }
      if (candidate.id != userId) {
        return const DiscoveryProfileResult.failure(DiscoveryError.unexpected);
      }
      return DiscoveryProfileResult.success(ranking.enrich(viewer, candidate));
    } on DiscoveryDataException catch (error) {
      return DiscoveryProfileResult.failure(error.code);
    } catch (_) {
      return const DiscoveryProfileResult.failure(DiscoveryError.unexpected);
    }
  }
}
