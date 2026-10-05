import 'package:flutter_test/flutter_test.dart';
import 'package:lovic/features/discovery/domain/discovery_config.dart';
import 'package:lovic/features/discovery/domain/discovery_profile.dart';
import 'package:lovic/features/discovery/domain/discovery_repository.dart';
import 'package:lovic/features/discovery/domain/rank_discovery.dart';
import 'package:lovic/features/music_profile/domain/music_profile.dart';

MusicProfile music(String id, {bool matches = true}) => MusicProfile(
  userId: id,
  artists: [
    MusicArtist(id: matches ? 'artist' : 'other-artist', name: 'Artist'),
  ],
  tracks: [MusicTrack(id: matches ? 'track' : 'other-track', name: 'Track')],
  genres: [matches ? 'mpb' : 'rock'],
  syncedAt: DateTime.utc(2026, 10, 5),
);

DiscoveryCandidate candidate(
  String id,
  double distance, {
  bool matches = true,
}) => DiscoveryCandidate(
  id: id,
  name: id,
  age: 25,
  bio: 'Bio',
  photoUrl: 'https://example.com/photo.jpg',
  musicProfile: music(id, matches: matches),
  distanceKm: distance,
);

class FakeDiscoverySource implements DiscoveryDataSource {
  List<DiscoveryCandidate> candidates;
  DiscoveryDataException? failure;
  double? requestedRadius;

  FakeDiscoverySource(this.candidates);

  @override
  Future<List<DiscoveryCandidate>> fetchNearby({
    required double radiusKm,
  }) async {
    requestedRadius = radiusKm;
    if (failure != null) throw failure!;
    return candidates;
  }

  @override
  Future<DiscoveryCandidate?> fetchProfile(String userId) async {
    if (failure != null) throw failure!;
    for (final candidate in candidates) {
      if (candidate.id == userId) return candidate;
    }
    return null;
  }
}

void main() {
  test(
    '80/20 dá prioridade à afinidade e usa proximidade como peso secundário',
    () {
      final profiles = RankDiscovery()(
        viewer: music('me'),
        candidates: [
          candidate('near', 0, matches: false),
          candidate('far', 30),
        ],
      );
      expect(profiles.map((profile) => profile.id), ['far', 'near']);
      expect(profiles.first.affinity, 100);
      expect(profiles.first.rankingScore, 80);
      expect(profiles.last.rankingScore, 20);
      expect(profiles.first.distanceKm, 30);
    },
  );

  test('filtra raio inclusivo, exclui próprio usuário e remove repetidos', () {
    final profiles = RankDiscovery()(
      viewer: music('me'),
      candidates: [
        candidate('me', 0),
        candidate('outside', 30.1),
        candidate('boundary', 30),
        candidate('boundary', 30),
      ],
    );
    expect(profiles.map((profile) => profile.id), ['boundary']);
    expect(() => profiles.clear(), throwsUnsupportedError);
  });

  test('empate é determinístico e proximidade ordena afinidades iguais', () {
    final profiles = RankDiscovery()(
      viewer: music('me'),
      candidates: [
        candidate('z', 10),
        candidate('a', 10),
        candidate('close', 2),
      ],
    );
    expect(profiles.map((profile) => profile.id), ['close', 'a', 'z']);
  });

  test('configuração central substitui raio e fórmula usa o mesmo raio', () {
    final rank = RankDiscovery(config: DiscoveryConfig(radiusKm: 10));
    final profiles = rank(
      viewer: music('me'),
      candidates: [candidate('within', 5), candidate('outside', 11)],
    );
    expect(profiles.single.rankingScore, 90);
    expect(() => DiscoveryConfig(radiusKm: 0), throwsArgumentError);
    expect(() => DiscoveryConfig(radiusKm: double.nan), throwsArgumentError);
    expect(() => DiscoveryConfig(affinityWeight: 0.9), throwsArgumentError);
  });

  test(
    'contrato rejeita distância inválida e perfil musical de outra identidade',
    () {
      expect(() => candidate('a', -1), throwsArgumentError);
      expect(() => candidate('a', double.infinity), throwsArgumentError);
      expect(
        () => DiscoveryCandidate(
          id: 'a',
          name: 'A',
          age: 25,
          bio: '',
          musicProfile: music('b'),
          distanceKm: 1,
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'repositório distingue lista vazia e falha e envia raio configurado',
    () async {
      final source = FakeDiscoverySource([]);
      final repository = DiscoveryRepository(
        dataSource: source,
        ranking: RankDiscovery(config: DiscoveryConfig(radiusKm: 12)),
      );
      final empty = await repository.discover(viewer: music('me'));
      expect(empty.isEmpty, isTrue);
      expect(empty.radiusKm, 12);
      expect(source.requestedRadius, 12);
      source.failure = const DiscoveryDataException(DiscoveryError.network);
      final failed = await repository.discover(viewer: music('me'));
      expect(failed.error, DiscoveryError.network);
      expect(failed.isEmpty, isFalse);
    },
  );

  test(
    'perfil completo reutiliza artistas/músicas salvos e distância segura',
    () async {
      final repository = DiscoveryRepository(
        dataSource: FakeDiscoverySource([candidate('a', 1.5)]),
      );
      final result = await repository.getProfile(
        viewer: music('me'),
        userId: 'a',
      );
      expect(result.profile!.artists.single.id, 'artist');
      expect(result.profile!.tracks.single.id, 'track');
      expect(result.profile!.genres, ['mpb']);
      expect(result.profile!.distanceKm, 1.5);
      final missing = await repository.getProfile(
        viewer: music('me'),
        userId: 'absent',
      );
      expect(missing.error, DiscoveryError.notFound);
    },
  );
}
