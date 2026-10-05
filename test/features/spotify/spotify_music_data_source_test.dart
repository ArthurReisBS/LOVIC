import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovic/features/spotify/data/spotify_music_data_source.dart';
import 'package:lovic/features/spotify/data/spotify_token.dart';
import 'package:lovic/features/spotify/data/spotify_token_provider.dart';
import 'package:lovic/features/spotify/domain/spotify_state.dart';

import 'spotify_test_support.dart';

void main() {
  final now = DateTime.utc(2026, 10, 5);
  final token = SpotifyToken(
    accessToken: 'test',
    refreshToken: 'r',
    expiresAt: now.add(const Duration(hours: 1)),
  );
  late Dio dio;
  late SpotifyTokenProvider tokens;

  setUp(() {
    dio = Dio();
    tokens = SpotifyTokenProvider(
      store: FakeTokenStore(token),
      oauth: FakeOAuth(token),
      now: () => now,
    );
  });

  test('reads top artists/tracks and derives normalized genres', () async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.queryParameters['time_range'], 'medium_term');
          expect(options.queryParameters['limit'], 50);
          final artists = options.path.endsWith('/artists');
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'items': [
                  if (artists)
                    {
                      'id': 'a',
                      'name': 'Artist',
                      'genres': [' POP ', 'pop'],
                      'images': [],
                    }
                  else
                    {
                      'id': 't',
                      'name': 'Track',
                      'artists': [
                        {'id': 'a'},
                      ],
                      'album': {
                        'images': [
                          {'url': 'https://img'},
                        ],
                      },
                    },
                ],
              },
            ),
          );
        },
      ),
    );
    final profile = await DioSpotifyMusicDataSource(
      tokens: tokens,
      dio: dio,
      now: () => now,
    ).fetchProfile('lovic-user');
    expect(profile.userId, 'lovic-user');
    expect(profile.genres, ['pop']);
    expect(profile.artists.single.imageUrl, isNull);
    expect(profile.tracks.single.imageUrl, 'https://img');
    expect(profile.tracks.single.artistIds, ['a']);
    expect(profile.syncedAt, now);
  });

  test(
    'rate limit respects Retry-After and suppresses immediate network retry',
    () async {
      var requests = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests++;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 429,
                  headers: Headers.fromMap({
                    'retry-after': ['120'],
                  }),
                ),
              ),
            );
          },
        ),
      );
      final source = DioSpotifyMusicDataSource(
        tokens: tokens,
        dio: dio,
        now: () => now,
      );
      await expectLater(
        source.fetchProfile('u'),
        throwsA(
          isA<SpotifyFailure>().having(
            (e) => e.retryAt,
            'retryAt',
            now.add(const Duration(seconds: 120)),
          ),
        ),
      );
      final previous = requests;
      await expectLater(
        source.fetchProfile('u'),
        throwsA(isA<SpotifyFailure>()),
      );
      expect(requests, previous);
    },
  );

  test('401 exposes only domain failure and expires credentials', () async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: options,
                statusCode: 401,
                data: {'error': 'technical detail'},
              ),
            ),
          );
        },
      ),
    );
    final source = DioSpotifyMusicDataSource(
      tokens: tokens,
      dio: dio,
      now: () => now,
    );
    await expectLater(
      source.fetchProfile('u'),
      throwsA(
        isA<SpotifyFailure>().having(
          (e) => e.code,
          'code',
          SpotifyFailureCode.expired,
        ),
      ),
    );
    expect(await tokens.status(), SpotifyConnectionStatus.expired);
  });
}
