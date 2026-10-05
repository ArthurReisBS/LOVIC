import 'spotify_state.dart';

/// UI entrypoint. Does not expose tokens, transport errors or API payloads.
abstract interface class SpotifyRepository {
  Future<SpotifyProfileState> load({bool forceRefresh = false});
  Future<SpotifyProfileState> connect();
  Future<SpotifyProfileState> disconnect();
}
