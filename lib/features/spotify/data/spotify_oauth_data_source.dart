import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../domain/spotify_state.dart';
import 'spotify_token.dart';

class SpotifyOAuthConfig {
  SpotifyOAuthConfig({required this.clientId, required this.redirectUri});

  final String clientId;
  final Uri redirectUri;

  void validate() {
    final isLoopback =
        redirectUri.scheme == 'http' &&
        (redirectUri.host == '127.0.0.1' || redirectUri.host == '[::1]');
    if (clientId.trim().isEmpty ||
        redirectUri.host.isEmpty ||
        redirectUri.userInfo.isNotEmpty ||
        redirectUri.hasQuery ||
        redirectUri.hasFragment ||
        !(redirectUri.scheme == 'https' || isLoopback)) {
      throw const SpotifyFailure(SpotifyFailureCode.notConfigured);
    }
  }
}

abstract interface class SpotifyAuthorizationBrowser {
  Future<Uri> authorize(Uri authorizationUri, Uri redirectUri);
}

class FlutterSpotifyAuthorizationBrowser
    implements SpotifyAuthorizationBrowser {
  @override
  Future<Uri> authorize(Uri authorizationUri, Uri redirectUri) async {
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authorizationUri.toString(),
        callbackUrlScheme: redirectUri.scheme,
        options: FlutterWebAuth2Options(
          httpsHost: redirectUri.scheme == 'https' ? redirectUri.host : null,
          httpsPath: redirectUri.scheme == 'https' ? redirectUri.path : null,
          useWebview: false,
        ),
      );
      return Uri.parse(result);
    } on PlatformException catch (error) {
      throw SpotifyFailure(
        error.code.toLowerCase().contains('cancel')
            ? SpotifyFailureCode.cancelled
            : SpotifyFailureCode.unavailable,
      );
    } catch (_) {
      throw const SpotifyFailure(SpotifyFailureCode.unavailable);
    }
  }
}

abstract interface class SpotifyOAuthDataSource {
  Future<SpotifyToken> connect();
  Future<SpotifyToken> refresh(SpotifyToken token);
}

/// Direct PKCE: only the public client ID enters the app, never a client secret.
class PkceSpotifyOAuthDataSource implements SpotifyOAuthDataSource {
  PkceSpotifyOAuthDataSource({
    required this.config,
    required this.browser,
    Dio? dio,
    DateTime Function()? now,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 20),
             ),
           ),
       _now = now ?? DateTime.now;

  final SpotifyOAuthConfig config;
  final SpotifyAuthorizationBrowser browser;
  final Dio _dio;
  final DateTime Function() _now;

  @override
  Future<SpotifyToken> connect() async {
    config.validate();
    final verifier = _randomString();
    final state = _randomString();
    final challenge = base64UrlEncode(
      sha256.convert(ascii.encode(verifier)).bytes,
    ).replaceAll('=', '');
    final uri = Uri.https('accounts.spotify.com', '/authorize', {
      'client_id': config.clientId,
      'redirect_uri': config.redirectUri.toString(),
      'response_type': 'code',
      'scope': 'user-top-read',
      'state': state,
      'code_challenge_method': 'S256',
      'code_challenge': challenge,
      'show_dialog': 'true',
    });
    final callback = await browser.authorize(uri, config.redirectUri);
    final expected = config.redirectUri;
    if (callback.scheme != expected.scheme ||
        callback.host != expected.host ||
        callback.port != expected.port ||
        callback.path != expected.path ||
        callback.queryParameters['state'] != state) {
      throw const SpotifyFailure(SpotifyFailureCode.invalidCallback);
    }
    if (callback.queryParameters.containsKey('error')) {
      throw const SpotifyFailure(SpotifyFailureCode.cancelled);
    }
    final code = callback.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw const SpotifyFailure(SpotifyFailureCode.invalidCallback);
    }
    return _exchange({
      'client_id': config.clientId,
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': config.redirectUri.toString(),
      'code_verifier': verifier,
    });
  }

  @override
  Future<SpotifyToken> refresh(SpotifyToken token) async {
    config.validate();
    final refresh = token.refreshToken;
    if (refresh == null || refresh.isEmpty) {
      throw const SpotifyFailure(SpotifyFailureCode.expired);
    }
    return _exchange({
      'client_id': config.clientId,
      'grant_type': 'refresh_token',
      'refresh_token': refresh,
    }, previousRefreshToken: refresh);
  }

  Future<SpotifyToken> _exchange(
    Map<String, String> data, {
    String? previousRefreshToken,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://accounts.spotify.com/api/token',
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final json = response.data!;
      final access = json['access_token'] as String;
      final seconds = json['expires_in'] as int;
      if (access.isEmpty || seconds <= 0 || json['token_type'] != 'Bearer') {
        throw const SpotifyFailure(SpotifyFailureCode.invalidData);
      }
      final scope = json['scope'] as String?;
      if (scope != null && !scope.split(' ').contains('user-top-read')) {
        throw const SpotifyFailure(SpotifyFailureCode.forbidden);
      }
      return SpotifyToken(
        accessToken: access,
        refreshToken: json['refresh_token'] as String? ?? previousRefreshToken,
        expiresAt: _now().toUtc().add(Duration(seconds: seconds)),
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if ((status == 400 &&
              error.response?.data is Map &&
              (error.response!.data as Map)['error'] == 'invalid_grant') ||
          status == 401) {
        throw const SpotifyFailure(SpotifyFailureCode.expired);
      }
      if (status == 429) {
        final seconds = int.tryParse(
          error.response?.headers.value('retry-after') ?? '',
        );
        throw SpotifyFailure(
          SpotifyFailureCode.rateLimited,
          retryAt: seconds == null
              ? null
              : _now().toUtc().add(Duration(seconds: seconds)),
        );
      }
      throw const SpotifyFailure(SpotifyFailureCode.unavailable);
    } on SpotifyFailure {
      rethrow;
    } catch (_) {
      throw const SpotifyFailure(SpotifyFailureCode.invalidData);
    }
  }

  String _randomString() {
    final random = Random.secure();
    return base64UrlEncode(
      List.generate(48, (_) => random.nextInt(256)),
    ).replaceAll('=', '');
  }
}
