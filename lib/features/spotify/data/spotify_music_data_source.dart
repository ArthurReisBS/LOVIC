import 'package:dio/dio.dart';

import '../../music_profile/domain/music_profile.dart';
import '../domain/spotify_state.dart';
import 'spotify_token_provider.dart';

abstract interface class SpotifyMusicDataSource {
  Future<MusicProfile> fetchProfile(String userId);
}

class DioSpotifyMusicDataSource implements SpotifyMusicDataSource {
  DioSpotifyMusicDataSource({
    required this.tokens,
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

  final SpotifyTokenProvider tokens;
  final Dio _dio;
  final DateTime Function() _now;
  DateTime? _retryAt;

  @override
  Future<MusicProfile> fetchProfile(String userId) async {
    if (_retryAt != null && _now().isBefore(_retryAt!)) {
      throw SpotifyFailure(SpotifyFailureCode.rateLimited, retryAt: _retryAt);
    }
    try {
      final access = await tokens.accessToken();
      // Both calls must succeed before replacing a previously valid profile.
      final responses = await Future.wait([
        _top('artists', access),
        _top('tracks', access),
      ]);
      final artists = _items(responses[0])
          .map(
            (item) => MusicArtist(
              id: item['id'] as String,
              name: item['name'] as String,
              imageUrl: _image(item['images']),
              genres: (item['genres'] as List? ?? []).cast<String>(),
            ),
          )
          .toList();
      final tracks = _items(responses[1])
          .map(
            (item) => MusicTrack(
              id: item['id'] as String,
              name: item['name'] as String,
              imageUrl: _image((item['album'] as Map?)?['images']),
              artistIds: (item['artists'] as List? ?? []).map(
                (artist) => (artist as Map)['id'] as String,
              ),
            ),
          )
          .toList();
      return MusicProfile(
        userId: userId,
        artists: artists,
        tracks: tracks,
        genres: artists.expand((artist) => artist.genres),
        syncedAt: _now(),
      );
    } on SpotifyFailure {
      rethrow;
    } catch (_) {
      throw const SpotifyFailure(SpotifyFailureCode.invalidData);
    }
  }

  Future<Map<String, dynamic>> _top(String type, String access) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.spotify.com/v1/me/top/$type',
        queryParameters: {'limit': 50, 'time_range': 'medium_term'},
        options: Options(headers: {'Authorization': 'Bearer $access'}),
      );
      return response.data!;
    } on DioException catch (error) {
      switch (error.response?.statusCode) {
        case 401:
          await tokens.invalidate();
          throw const SpotifyFailure(SpotifyFailureCode.expired);
        case 403:
          await tokens.invalidate();
          throw const SpotifyFailure(SpotifyFailureCode.forbidden);
        case 429:
          final seconds = int.tryParse(
            error.response?.headers.value('retry-after') ?? '',
          );
          _retryAt = _now().toUtc().add(Duration(seconds: seconds ?? 60));
          throw SpotifyFailure(
            SpotifyFailureCode.rateLimited,
            retryAt: _retryAt,
          );
        default:
          throw const SpotifyFailure(SpotifyFailureCode.unavailable);
      }
    }
  }

  List<Map<String, dynamic>> _items(Map<String, dynamic> json) =>
      (json['items'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

  String? _image(dynamic value) {
    if (value is! List || value.isEmpty) return null;
    return (value.first as Map)['url'] as String?;
  }
}
