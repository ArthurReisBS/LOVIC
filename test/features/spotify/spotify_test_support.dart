import 'package:lovic/features/music_profile/domain/music_profile.dart';
import 'package:lovic/features/spotify/data/spotify_music_data_source.dart';
import 'package:lovic/features/spotify/data/spotify_oauth_data_source.dart';
import 'package:lovic/features/spotify/data/spotify_token.dart';
import 'package:lovic/features/spotify/domain/spotify_state.dart';

class FakeTokenStore implements SpotifyTokenStore {
  FakeTokenStore(this.token);
  SpotifyToken? token;
  @override
  Future<SpotifyToken?> read() async => token;
  @override
  Future<void> write(SpotifyToken value) async => token = value;
  @override
  Future<void> clear() async => token = null;
}

class FakeOAuth implements SpotifyOAuthDataSource {
  FakeOAuth(this.newToken);
  final SpotifyToken newToken;
  int refreshCalls = 0;
  SpotifyFailure? failure;
  @override
  Future<SpotifyToken> connect() async => newToken;
  @override
  Future<SpotifyToken> refresh(SpotifyToken token) async {
    refreshCalls++;
    await Future<void>.delayed(Duration.zero);
    if (failure != null) throw failure!;
    return newToken;
  }
}

class FakeMusic implements SpotifyMusicDataSource {
  FakeMusic(this.profile);
  final MusicProfile profile;
  SpotifyFailure? failure;
  int calls = 0;
  @override
  Future<MusicProfile> fetchProfile(String userId) async {
    calls++;
    if (failure != null) throw failure!;
    return profile;
  }
}

class CallbackBrowser implements SpotifyAuthorizationBrowser {
  CallbackBrowser(this.callback);
  final Uri Function(Uri authorization, Uri redirect) callback;
  @override
  Future<Uri> authorize(Uri authorizationUri, Uri redirectUri) async =>
      callback(authorizationUri, redirectUri);
}
