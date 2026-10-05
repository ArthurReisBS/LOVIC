import '../../music_profile/domain/music_profile.dart';

/// Explainable musical compatibility; all scores use the range 0..100.
class AffinityResult {
  AffinityResult._({
    required this.score,
    required this.artistScore,
    required this.genreScore,
    required this.trackScore,
    required Iterable<String> commonArtistIds,
    required Iterable<String> commonGenres,
    required Iterable<String> commonTrackIds,
  }) : commonArtistIds = List.unmodifiable(commonArtistIds),
       commonGenres = List.unmodifiable(commonGenres),
       commonTrackIds = List.unmodifiable(commonTrackIds);

  final double score;
  final double artistScore;
  final double genreScore;
  final double trackScore;
  final List<String> commonArtistIds;
  final List<String> commonGenres;
  final List<String> commonTrackIds;
}

/// Pure, deterministic Jaccard comparison with the agreed 50/30/20 weights.
///
/// Empty components contribute zero and weights are never redistributed.
/// See ../README.md for the formula and normalization contract.
class AffinityService {
  const AffinityService();

  static const artistWeight = 0.50;
  static const genreWeight = 0.30;
  static const trackWeight = 0.20;

  AffinityResult calculate(MusicProfile own, MusicProfile candidate) {
    final artists = _compare(
      _ids(own.artists.map((artist) => artist.id)),
      _ids(candidate.artists.map((artist) => artist.id)),
    );
    final genres = _compare(_genres(own.genres), _genres(candidate.genres));
    final tracks = _compare(
      _ids(own.tracks.map((track) => track.id)),
      _ids(candidate.tracks.map((track) => track.id)),
    );

    final weighted =
        artists.score * artistWeight +
        genres.score * genreWeight +
        tracks.score * trackWeight;

    return AffinityResult._(
      score: weighted.clamp(0.0, 100.0).toDouble(),
      artistScore: artists.score,
      genreScore: genres.score,
      trackScore: tracks.score,
      commonArtistIds: artists.common,
      commonGenres: genres.common,
      commonTrackIds: tracks.common,
    );
  }

  Set<String> _ids(Iterable<String> items) =>
      items.map((item) => item.trim()).where((item) => item.isNotEmpty).toSet();

  Set<String> _genres(Iterable<String> items) => items
      .map((item) => item.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' '))
      .where((item) => item.isNotEmpty)
      .toSet();

  ({double score, List<String> common}) _compare(
    Set<String> first,
    Set<String> second,
  ) {
    final common = first.intersection(second).toList()..sort();
    final unionSize = first.union(second).length;
    return (
      score: unionSize == 0 ? 0.0 : 100.0 * common.length / unionSize,
      common: common,
    );
  }
}
