import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/spotify_state.dart';

/// Private infrastructure model. UI only sees SpotifyConnectionStatus.
class SpotifyToken {
  const SpotifyToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;

  bool isValidAt(DateTime now) =>
      expiresAt.isAfter(now.add(const Duration(seconds: 30)));

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  };

  factory SpotifyToken.fromJson(Map<String, dynamic> json) {
    final access = json['accessToken'] as String;
    if (access.isEmpty) {
      throw const FormatException('Invalid stored credential');
    }
    return SpotifyToken(
      accessToken: access,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: DateTime.parse(json['expiresAt'] as String).toUtc(),
    );
  }

  @override
  String toString() => 'SpotifyToken(redacted)';
}

abstract interface class SpotifyTokenStore {
  Future<SpotifyToken?> read();
  Future<void> write(SpotifyToken token);
  Future<void> clear();
}

/// One store per authenticated LOVIC user. No shared global token key.
class SecureSpotifyTokenStore implements SpotifyTokenStore {
  SecureSpotifyTokenStore({
    required String userId,
    FlutterSecureStorage? storage,
  }) : _key = 'lovic.spotify.${Uri.encodeComponent(userId)}',
       _storage = storage ?? const FlutterSecureStorage() {
    if (userId.trim().isEmpty) throw ArgumentError('userId is required');
  }

  final String _key;
  final FlutterSecureStorage _storage;

  @override
  Future<SpotifyToken?> read() async {
    try {
      final value = await _storage.read(key: _key);
      return value == null
          ? null
          : SpotifyToken.fromJson(
              Map<String, dynamic>.from(jsonDecode(value) as Map),
            );
    } on FormatException {
      await clear();
      return null;
    } on TypeError {
      await clear();
      return null;
    } catch (_) {
      throw const SpotifyFailure(SpotifyFailureCode.storageUnavailable);
    }
  }

  @override
  Future<void> write(SpotifyToken token) async {
    try {
      await _storage.write(key: _key, value: jsonEncode(token.toJson()));
    } catch (_) {
      throw const SpotifyFailure(SpotifyFailureCode.storageUnavailable);
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {
      throw const SpotifyFailure(SpotifyFailureCode.storageUnavailable);
    }
  }
}
