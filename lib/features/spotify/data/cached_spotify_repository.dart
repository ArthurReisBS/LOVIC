import '../../music_profile/domain/music_profile.dart';
import '../../music_profile/domain/music_profile_store.dart';
import '../domain/spotify_repository.dart';
import '../domain/spotify_state.dart';
import 'spotify_music_data_source.dart';
import 'spotify_token_provider.dart';

class CachedSpotifyRepository implements SpotifyRepository {
  CachedSpotifyRepository({
    required this.userId,
    required this.tokens,
    required this.remote,
    required this.cache,
    this.persistedProfiles,
    this.cacheTtl = const Duration(hours: 24),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now {
    if (userId.trim().isEmpty || cacheTtl.isNegative) {
      throw ArgumentError('Invalid cache config');
    }
  }

  final String userId;
  final SpotifyTokenProvider tokens;
  final SpotifyMusicDataSource remote;
  final MusicProfileStore cache;
  final MusicProfileStore? persistedProfiles;

  /// Documented technical fallback; inject central configuration when available.
  final Duration cacheTtl;
  final DateTime Function() _now;
  Future<SpotifyProfileState>? _pending;

  @override
  Future<SpotifyProfileState> load({bool forceRefresh = false}) =>
      _pending ??= _load(forceRefresh).whenComplete(() => _pending = null);

  Future<SpotifyProfileState> _load(bool forceRefresh) async {
    MusicProfile? saved;
    var status = SpotifyConnectionStatus.notConnected;
    SpotifyFailure? storeFailure;
    try {
      try {
        final cached = await cache.read(userId);
        if (cached != null) {
          _validateOwner(cached);
          saved = cached;
        }
      } on SpotifyFailure {
        rethrow;
      } catch (_) {
        storeFailure = const SpotifyFailure(
          SpotifyFailureCode.storageUnavailable,
        );
      }
      if (saved == null && persistedProfiles != null) {
        try {
          final persisted = await persistedProfiles!.read(userId);
          if (persisted != null) {
            _validateOwner(persisted);
            saved = persisted;
            await cache.write(persisted);
          }
        } catch (_) {
          storeFailure = const SpotifyFailure(
            SpotifyFailureCode.storageUnavailable,
          );
        }
      }
      if (saved != null) _validateOwner(saved);
      status = await tokens.status();
      final fresh =
          saved != null &&
          !saved.syncedAt.isAfter(_now().toUtc()) &&
          _now().toUtc().difference(saved.syncedAt) < cacheTtl;
      if ((!forceRefresh && fresh) ||
          status == SpotifyConnectionStatus.notConnected) {
        return SpotifyProfileState(
          status: status,
          profile: saved,
          isCached: saved != null,
          failure: storeFailure,
        );
      }
      final profile = await remote.fetchProfile(userId);
      _validateOwner(profile);
      await cache.write(profile);
      if (persistedProfiles != null) {
        try {
          await persistedProfiles!.write(profile);
        } catch (_) {
          storeFailure = const SpotifyFailure(
            SpotifyFailureCode.storageUnavailable,
          );
        }
      }
      return SpotifyProfileState(
        status: SpotifyConnectionStatus.connected,
        profile: profile,
        failure: storeFailure,
      );
    } on SpotifyFailure catch (failure) {
      if (failure.code == SpotifyFailureCode.expired ||
          failure.code == SpotifyFailureCode.forbidden) {
        status = SpotifyConnectionStatus.expired;
      }
      return SpotifyProfileState(
        status: status,
        profile: saved,
        isCached: saved != null,
        failure: failure,
      );
    } catch (_) {
      return SpotifyProfileState(
        status: status,
        profile: saved,
        isCached: saved != null,
        failure: const SpotifyFailure(SpotifyFailureCode.storageUnavailable),
      );
    }
  }

  @override
  Future<SpotifyProfileState> connect() async {
    try {
      await tokens.connect();
      // Wait for an existing load to finish, then force synchronization.
      if (_pending != null) await _pending;
      return load(forceRefresh: true);
    } on SpotifyFailure catch (failure) {
      final current = await load();
      return SpotifyProfileState(
        status: current.status,
        profile: current.profile,
        isCached: current.isCached,
        failure: failure,
      );
    }
  }

  @override
  Future<SpotifyProfileState> disconnect() async {
    // A pending refresh must finish before clearing, to avoid resurrecting tokens.
    if (_pending != null) await _pending;
    await tokens.disconnect();
    return load();
  }

  void _validateOwner(MusicProfile profile) {
    if (profile.userId != userId) {
      throw const SpotifyFailure(SpotifyFailureCode.invalidData);
    }
  }
}
