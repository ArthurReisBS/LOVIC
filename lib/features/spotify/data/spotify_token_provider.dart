import '../domain/spotify_state.dart';
import 'spotify_oauth_data_source.dart';
import 'spotify_token.dart';

/// The only abstraction that owns credentials/refresh. Not exposed to widgets.
class SpotifyTokenProvider {
  SpotifyTokenProvider({
    required this.store,
    required this.oauth,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final SpotifyTokenStore store;
  final SpotifyOAuthDataSource oauth;
  final DateTime Function() _now;
  Future<String>? _pendingRefresh;
  Future<void>? _pendingConnect;

  Future<SpotifyConnectionStatus> status() async {
    final token = await store.read();
    if (token == null) return SpotifyConnectionStatus.notConnected;
    return token.isValidAt(_now())
        ? SpotifyConnectionStatus.connected
        : SpotifyConnectionStatus.expired;
  }

  Future<void> connect() {
    return _pendingConnect ??= _connect().whenComplete(
      () => _pendingConnect = null,
    );
  }

  Future<void> _connect() async => store.write(await oauth.connect());

  Future<String> accessToken() async {
    final token = await store.read();
    if (token == null) {
      throw const SpotifyFailure(SpotifyFailureCode.notConnected);
    }
    if (token.isValidAt(_now())) return token.accessToken;
    return _pendingRefresh ??= _refresh(
      token,
    ).whenComplete(() => _pendingRefresh = null);
  }

  Future<String> _refresh(SpotifyToken token) async {
    try {
      final refreshed = await oauth.refresh(token);
      await store.write(refreshed);
      return refreshed.accessToken;
    } on SpotifyFailure catch (failure) {
      if (failure.code == SpotifyFailureCode.expired) await invalidate();
      rethrow;
    }
  }

  /// Keep expired marker so a rejected credential is shown as reconnectable.
  Future<void> invalidate() async {
    final token = await store.read();
    if (token == null) return;
    await store.write(
      SpotifyToken(
        accessToken: token.accessToken,
        refreshToken: null,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      ),
    );
  }

  /// Backend A should invoke on logout/account removal before disposing scope.
  Future<void> disconnect() async {
    // Complete in-flight credential writes before removing this account's key.
    await _settle(_pendingConnect);
    await _settle(_pendingRefresh);
    await store.clear();
  }

  Future<void> _settle(Future<dynamic>? operation) async {
    if (operation == null) return;
    try {
      await operation;
    } catch (_) {
      // Failure cannot prevent logout cleanup, but another pending credential
      // write still has to settle before the token is cleared.
    }
  }
}
