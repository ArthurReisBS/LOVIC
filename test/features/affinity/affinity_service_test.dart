import 'package:flutter_test/flutter_test.dart';
import 'package:lovic/features/affinity/domain/affinity_service.dart';
import 'package:lovic/features/music_profile/domain/music_profile.dart';

void main() {
  const service = AffinityService();

  test('identical complete profiles have affinity 100', () {
    final result = service.calculate(_profile(), _profile());

    expect(result.score, 100);
    expect(result.artistScore, 100);
    expect(result.genreScore, 100);
    expect(result.trackScore, 100);
    expect(result.commonArtistIds, ['artist-1', 'artist-2']);
    expect(result.commonGenres, ['pop', 'rock']);
    expect(result.commonTrackIds, ['track-1', 'track-2']);
  });

  test('profiles with no common items have affinity zero', () {
    final result = service.calculate(
      _profile(),
      _profile(artists: ['different'], genres: ['jazz'], tracks: ['different']),
    );

    expect(result.score, 0);
    expect(result.commonArtistIds, isEmpty);
    expect(result.commonGenres, isEmpty);
    expect(result.commonTrackIds, isEmpty);
  });

  for (final component in [
    (
      name: 'artists',
      artists: ['artist-1', 'artist-2'],
      genres: <String>[],
      tracks: <String>[],
      score: 50,
    ),
    (
      name: 'genres',
      artists: <String>[],
      genres: ['pop', 'rock'],
      tracks: <String>[],
      score: 30,
    ),
    (
      name: 'tracks',
      artists: <String>[],
      genres: <String>[],
      tracks: ['track-1', 'track-2'],
      score: 20,
    ),
  ]) {
    test('only ${component.name} in common contributes its fixed weight', () {
      final result = service.calculate(
        _profile(),
        _profile(
          artists: component.artists,
          genres: component.genres,
          tracks: component.tracks,
        ),
      );

      expect(result.score, component.score);
    });
  }

  test(
    'both empty profiles have zero affinity without weight redistribution',
    () {
      final empty = _profile(artists: [], genres: [], tracks: []);

      expect(service.calculate(empty, empty).score, 0);
      expect(service.calculate(_profile(), empty).score, 0);
      expect(service.calculate(empty, _profile()).score, 0);
      final artistsOnly = _profile(genres: [], tracks: []);
      expect(service.calculate(artistsOnly, artistsOnly).score, 50);
    },
  );

  test(
    'duplicates, empty entries and reordered lists cannot inflate affinity',
    () {
      final noisy = _profile(
        artists: ['artist-2', 'artist-1', ' artist-1 '],
        genres: ['ROCK', ' pop ', 'Pop', '', '   '],
        tracks: ['track-2', 'track-1', ' track-1 '],
      );

      final result = service.calculate(noisy, _profile());
      expect(result.score, 100);
      expect(result.commonArtistIds, ['artist-1', 'artist-2']);
      expect(result.commonGenres, ['pop', 'rock']);
      expect(result.commonTrackIds, ['track-1', 'track-2']);
    },
  );

  test('Jaccard divides by distinct union and comparison is symmetric', () {
    final first = _profile(
      artists: ['a', 'b'],
      genres: ['pop', 'rock'],
      tracks: ['t'],
    );
    final second = _profile(
      artists: ['b', 'c'],
      genres: ['pop'],
      tracks: ['t', 'u'],
    );
    final result = service.calculate(first, second);
    final reversed = service.calculate(second, first);

    expect(result.artistScore, closeTo(100 / 3, 1e-10));
    expect(result.genreScore, 50);
    expect(result.trackScore, 50);
    expect(result.score, closeTo(50 / 3 + 15 + 10, 1e-10));
    expect(reversed.score, result.score);
    expect(reversed.commonArtistIds, result.commonArtistIds);
    expect(reversed.commonGenres, result.commonGenres);
    expect(reversed.commonTrackIds, result.commonTrackIds);
    expect(result.score, inInclusiveRange(0, 100));
  });

  test(
    'IDs remain case-sensitive and genres normalize repeated whitespace',
    () {
      final result = service.calculate(
        _profile(
          artists: ['SpotifyID'],
          genres: [' Indie   Rock '],
          tracks: ['ID'],
        ),
        _profile(
          artists: ['spotifyid'],
          genres: ['indie rock'],
          tracks: ['id'],
        ),
      );

      expect(result.artistScore, 0);
      expect(result.trackScore, 0);
      expect(result.genreScore, 100);
      expect(result.score, 30);
    },
  );

  test('common item lists cannot be mutated by consumers', () {
    final result = service.calculate(_profile(), _profile());

    expect(() => result.commonArtistIds.add('another'), throwsUnsupportedError);
    expect(() => result.commonGenres.clear(), throwsUnsupportedError);
    expect(() => result.commonTrackIds.add('another'), throwsUnsupportedError);
  });
}

MusicProfile _profile({
  List<String> artists = const ['artist-1', 'artist-2'],
  List<String> genres = const ['pop', 'rock'],
  List<String> tracks = const ['track-1', 'track-2'],
}) => MusicProfile(
  userId: 'test-user',
  artists: artists.map((id) => MusicArtist(id: id, name: 'Artist $id')),
  tracks: tracks.map((id) => MusicTrack(id: id, name: 'Track $id')),
  genres: genres,
  syncedAt: DateTime.utc(2026, 10, 5),
);
