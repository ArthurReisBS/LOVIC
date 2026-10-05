import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/discovery/domain/discovery_repository.dart';
import '../features/location/domain/location_repository.dart';
import '../features/matches/domain/like_repository.dart';
import '../features/spotify/domain/spotify_repository.dart';
import '../features/spotify/domain/spotify_state.dart';

/// Composition points for the frontend. The application bootstrap must
/// override the providers whose adapters belong to Backend A.
Never _missingAdapter(String owner) => throw StateError(
  'Adaptador de $owner não configurado. Substitua o provider no bootstrap.',
);

final spotifyRepositoryProvider = Provider<SpotifyRepository>(
  (ref) => _missingAdapter('Spotify/Backend B'),
);

final spotifyProfileStateProvider = FutureProvider<SpotifyProfileState>(
  (ref) => ref.watch(spotifyRepositoryProvider).load(),
);

final discoveryRepositoryProvider = Provider<DiscoveryRepository>(
  (ref) => _missingAdapter('descoberta do Backend A'),
);

final ownLocationRepositoryProvider = Provider<LocationRepository>(
  (ref) => _missingAdapter('persistência de localização do Backend A'),
);

final likeRepositoryProvider = Provider<LikeRepository>(
  (ref) => _missingAdapter('curtir/match do Backend A'),
);
