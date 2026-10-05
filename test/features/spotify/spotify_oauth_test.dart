import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovic/features/spotify/data/spotify_oauth_data_source.dart';
import 'package:lovic/features/spotify/data/spotify_token.dart';
import 'package:lovic/features/spotify/data/spotify_token_provider.dart';
import 'package:lovic/features/spotify/domain/spotify_state.dart';

import 'spotify_test_support.dart';

void main() {
  final now = DateTime.utc(2026, 10, 5);
  final token = SpotifyToken(
    accessToken: 'new',
    refreshToken: 'r',
    expiresAt: now.add(const Duration(hours: 1)),
  );

  test(
    'expired concurrent calls refresh once through token provider',
    () async {
      final store = FakeTokenStore(
        SpotifyToken(accessToken: 'old', refreshToken: 'r', expiresAt: now),
      );
      final oauth = FakeOAuth(token);
      final tokens = SpotifyTokenProvider(
        store: store,
        oauth: oauth,
        now: () => now,
      );
      expect(await tokens.status(), SpotifyConnectionStatus.expired);
      expect(await Future.wait([tokens.accessToken(), tokens.accessToken()]), [
        'new',
        'new',
      ]);
      expect(oauth.refreshCalls, 1);
      expect(await tokens.status(), SpotifyConnectionStatus.connected);
    },
  );

  test(
    'invalid refresh remains expired without retrying rejected refresh token',
    () async {
      final store = FakeTokenStore(
        SpotifyToken(accessToken: 'old', refreshToken: 'r', expiresAt: now),
      );
      final oauth = FakeOAuth(token)
        ..failure = const SpotifyFailure(SpotifyFailureCode.expired);
      final tokens = SpotifyTokenProvider(
        store: store,
        oauth: oauth,
        now: () => now,
      );
      await expectLater(tokens.accessToken(), throwsA(isA<SpotifyFailure>()));
      expect(store.token!.refreshToken, isNull);
      expect(await tokens.status(), SpotifyConnectionStatus.expired);
    },
  );

  test(
    'PKCE exchanges code only after matching state and exact callback',
    () async {
      final dio = Dio();
      Uri? authorization;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final data = options.data as Map;
            final challenge = base64UrlEncode(
              sha256
                  .convert(ascii.encode(data['code_verifier'] as String))
                  .bytes,
            ).replaceAll('=', '');
            expect(authorization!.queryParameters['code_challenge'], challenge);
            expect(authorization!.queryParameters['scope'], 'user-top-read');
            expect(data.containsKey('client_secret'), isFalse);
            expect(data['code'], 'code');
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'access_token': 'access',
                  'refresh_token': 'refresh',
                  'token_type': 'Bearer',
                  'expires_in': 3600,
                  'scope': 'user-top-read',
                },
              ),
            );
          },
        ),
      );
      final oauth = PkceSpotifyOAuthDataSource(
        config: SpotifyOAuthConfig(
          clientId: 'public-id',
          redirectUri: Uri.parse('https://lovic.example/spotify'),
        ),
        browser: CallbackBrowser((uri, redirect) {
          authorization = uri;
          return redirect.replace(
            queryParameters: {
              'state': uri.queryParameters['state']!,
              'code': 'code',
            },
          );
        }),
        dio: dio,
        now: () => now,
      );
      final result = await oauth.connect();
      expect(result.expiresAt, now.add(const Duration(hours: 1)));
      expect(result.toString(), isNot(contains('access')));
    },
  );

  test('rejects forged callback state before any token request', () async {
    final oauth = PkceSpotifyOAuthDataSource(
      config: SpotifyOAuthConfig(
        clientId: 'public',
        redirectUri: Uri.parse('https://lovic.example/spotify'),
      ),
      browser: CallbackBrowser(
        (uri, redirect) => redirect.replace(
          queryParameters: {'code': 'code', 'state': 'forged'},
        ),
      ),
    );
    await expectLater(
      oauth.connect(),
      throwsA(
        isA<SpotifyFailure>().having(
          (e) => e.code,
          'code',
          SpotifyFailureCode.invalidCallback,
        ),
      ),
    );
  });

  test('refresh keeps previous refresh token when response omits it', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'access_token': 'fresh',
              'token_type': 'Bearer',
              'expires_in': 3600,
            },
          ),
        ),
      ),
    );
    final oauth = PkceSpotifyOAuthDataSource(
      config: SpotifyOAuthConfig(
        clientId: 'public',
        redirectUri: Uri.parse('https://lovic.example/spotify'),
      ),
      browser: CallbackBrowser((uri, redirect) => redirect),
      dio: dio,
      now: () => now,
    );
    expect((await oauth.refresh(token)).refreshToken, token.refreshToken);
  });

  test('rejects insecure production redirect and empty configuration', () {
    expect(
      () => SpotifyOAuthConfig(
        clientId: '',
        redirectUri: Uri.parse('https://app.example/cb'),
      ).validate(),
      throwsA(isA<SpotifyFailure>()),
    );
    expect(
      () => SpotifyOAuthConfig(
        clientId: 'id',
        redirectUri: Uri.parse('http://app.example/cb'),
      ).validate(),
      throwsA(isA<SpotifyFailure>()),
    );
  });

  test('disconnect waits for every pending credential write', () async {
    final expired = SpotifyToken(
      accessToken: 'old',
      refreshToken: 'r',
      expiresAt: now,
    );
    final store = FakeTokenStore(expired);
    final oauth = _ControlledOAuth();
    final tokens = SpotifyTokenProvider(
      store: store,
      oauth: oauth,
      now: () => now,
    );

    final connect = tokens.connect();
    final refresh = tokens.accessToken();
    await Future<void>.delayed(Duration.zero);
    final disconnect = tokens.disconnect();

    oauth.connectResult.completeError(
      const SpotifyFailure(SpotifyFailureCode.cancelled),
    );
    await expectLater(connect, throwsA(isA<SpotifyFailure>()));
    oauth.refreshResult.complete(token);
    expect(await refresh, 'new');
    await disconnect;

    expect(store.token, isNull);
  });
}

class _ControlledOAuth implements SpotifyOAuthDataSource {
  final connectResult = Completer<SpotifyToken>();
  final refreshResult = Completer<SpotifyToken>();

  @override
  Future<SpotifyToken> connect() => connectResult.future;

  @override
  Future<SpotifyToken> refresh(SpotifyToken token) => refreshResult.future;
}
