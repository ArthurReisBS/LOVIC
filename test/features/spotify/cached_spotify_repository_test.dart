import 'package:flutter_test/flutter_test.dart';
import 'package:lovic/features/music_profile/domain/music_profile.dart';
import 'package:lovic/features/music_profile/domain/music_profile_store.dart';
import 'package:lovic/features/spotify/data/cached_spotify_repository.dart';
import 'package:lovic/features/spotify/data/spotify_token.dart';
import 'package:lovic/features/spotify/data/spotify_token_provider.dart';
import 'package:lovic/features/spotify/domain/spotify_state.dart';

import 'spotify_test_support.dart';

void main() {
  final now = DateTime.utc(2026, 10, 5, 12);
  final token = SpotifyToken(
    accessToken: 'test',
    refreshToken: 'refresh',
    expiresAt: now.add(const Duration(hours: 1)),
  );
  MusicProfile profile(String user, DateTime synced) => MusicProfile(
    userId: user,
    artists: [MusicArtist(id: 'a', name: 'Artist')],
    syncedAt: synced,
  );
  late MemoryMusicProfileStore cache;
  late FakeTokenStore store;
  late FakeMusic remote;
  late CachedSpotifyRepository repository;

  setUp(() {
    cache = MemoryMusicProfileStore();
    store = FakeTokenStore(token);
    remote = FakeMusic(profile('u', now));
    repository = CachedSpotifyRepository(
      userId: 'u',
      cache: cache,
      remote: remote,
      tokens: SpotifyTokenProvider(
        store: store,
        oauth: FakeOAuth(token),
        now: () => now,
      ),
      now: () => now,
    );
  });

  test('reuses fresh cache without calling Spotify', () async {
    final saved = profile('u', now.subtract(const Duration(hours: 1)));
    await cache.write(saved);
    final state = await repository.load();
    expect(state.profile, same(saved));
    expect(state.status, SpotifyConnectionStatus.connected);
    expect(state.isCached, isTrue);
    expect(remote.calls, 0);
  });

  test('API failure retains last valid stale profile and timestamp', () async {
    final saved = profile('u', now.subtract(const Duration(days: 2)));
    await cache.write(saved);
    remote.failure = const SpotifyFailure(SpotifyFailureCode.rateLimited);
    final state = await repository.load();
    expect(state.profile, same(saved));
    expect(state.failure?.code, SpotifyFailureCode.rateLimited);
    expect(state.isCached, isTrue);
    expect(state.profile!.syncedAt, saved.syncedAt);
  });

  test(
    'sync stores real profile once and cached load skips new request',
    () async {
      final state = await repository.load();
      expect(state.profile, same(remote.profile));
      expect(state.isCached, isFalse);
      await repository.load();
      expect(remote.calls, 1);
    },
  );

  test('empty/not connected is a valid state without network', () async {
    store.token = null;
    final state = await repository.load();
    expect(state.status, SpotifyConnectionStatus.notConnected);
    expect(state.isEmpty, isTrue);
    expect(remote.calls, 0);
  });

  test(
    'expired state retains cache; reconnect forces synchronization',
    () async {
      await cache.write(profile('u', now));
      store.token = SpotifyToken(
        accessToken: 'old',
        refreshToken: null,
        expiresAt: now.subtract(const Duration(hours: 1)),
      );
      expect((await repository.load()).status, SpotifyConnectionStatus.expired);
      expect(remote.calls, 0);
      final state = await repository.connect();
      expect(state.status, SpotifyConnectionStatus.connected);
      expect(state.isCached, isFalse);
      expect(remote.calls, 1);
    },
  );

  test('other account cache never appears in the result', () async {
    repository = CachedSpotifyRepository(
      userId: 'u',
      cache: WrongOwnerStore(profile('other', now)),
      remote: remote,
      tokens: SpotifyTokenProvider(
        store: store,
        oauth: FakeOAuth(token),
        now: () => now,
      ),
      now: () => now,
    );
    final state = await repository.load();
    expect(state.profile, isNull);
    expect(state.failure?.code, SpotifyFailureCode.invalidData);
  });

  test(
    'broken memory cache still loads persisted profile and token state',
    () async {
      final persisted = MemoryMusicProfileStore();
      final saved = profile('u', now.subtract(const Duration(hours: 1)));
      await persisted.write(saved);
      repository = CachedSpotifyRepository(
        userId: 'u',
        cache: FailingStore(),
        persistedProfiles: persisted,
        remote: remote,
        tokens: SpotifyTokenProvider(
          store: store,
          oauth: FakeOAuth(token),
          now: () => now,
        ),
        now: () => now,
      );

      final state = await repository.load();

      expect(state.profile, same(saved));
      expect(state.status, SpotifyConnectionStatus.connected);
      expect(state.isCached, isTrue);
      expect(state.failure?.code, SpotifyFailureCode.storageUnavailable);
      expect(remote.calls, 0);
    },
  );
}

class WrongOwnerStore implements MusicProfileStore {
  WrongOwnerStore(this.profile);
  final MusicProfile profile;
  @override
  Future<MusicProfile?> read(String userId) async => profile;
  @override
  Future<void> write(MusicProfile profile) async {}
}

class FailingStore implements MusicProfileStore {
  @override
  Future<MusicProfile?> read(String userId) => throw StateError('cache');

  @override
  Future<void> write(MusicProfile profile) => throw StateError('cache');
}
