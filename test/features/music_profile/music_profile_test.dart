import 'package:flutter_test/flutter_test.dart';
import 'package:lovic/features/music_profile/domain/music_profile.dart';

void main() {
  test('normalizes genre case/spacing and freezes collections', () {
    final source = [' POP ', 'pop', '  indie   rock ', ''];
    final artist = MusicArtist(id: 'a', name: 'Artist', genres: source);
    source.add('jazz');
    expect(artist.genres, ['indie rock', 'pop']);
    expect(() => artist.genres.add('jazz'), throwsUnsupportedError);
  });

  test('stable JSON round trip includes images and UTC syncedAt', () {
    final profile = MusicProfile(
      userId: 'lovic-user',
      artists: [
        MusicArtist(id: 'a', name: 'Artist', imageUrl: 'https://image/a'),
      ],
      tracks: [
        MusicTrack(id: 't', name: 'Track', artistIds: ['a']),
      ],
      genres: [' POP '],
      syncedAt: DateTime.parse('2026-10-05T10:00:00-03:00'),
    );
    final restored = MusicProfile.fromJson(profile.toJson());
    expect(restored.toJson(), profile.toJson());
    expect(restored.syncedAt.isUtc, isTrue);
    expect(restored.artists.single.imageUrl, 'https://image/a');
  });

  test('deduplicates IDs, preserves ordering and rejects blank identity', () {
    final profile = MusicProfile(
      userId: 'u',
      artists: [
        MusicArtist(id: 'a', name: 'A'),
        MusicArtist(id: 'a', name: 'A'),
      ],
      syncedAt: DateTime.utc(2026),
    );
    expect(profile.artists, hasLength(1));
    expect(() => MusicTrack(id: '', name: 'A'), throwsArgumentError);
  });
}
