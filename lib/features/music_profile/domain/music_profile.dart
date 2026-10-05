/// Stable music data shared by discovery, profile and affinity services.
/// Contains no Spotify credentials or personal Spotify account metadata.
class MusicArtist {
  MusicArtist({
    required this.id,
    required this.name,
    this.imageUrl,
    Iterable<String> genres = const [],
  }) : genres = normalizeGenres(genres) {
    _requireText(id, 'id');
    _requireText(name, 'name');
  }

  final String id;
  final String name;
  final String? imageUrl;
  final List<String> genres;

  factory MusicArtist.fromJson(Map<String, dynamic> json) => MusicArtist(
    id: json['id'] as String,
    name: json['name'] as String,
    imageUrl: json['imageUrl'] as String?,
    genres: (json['genres'] as List? ?? []).cast<String>(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'genres': genres,
  };
}

class MusicTrack {
  MusicTrack({
    required this.id,
    required this.name,
    this.imageUrl,
    Iterable<String> artistIds = const [],
  }) : artistIds = List.unmodifiable(artistIds.toSet()) {
    _requireText(id, 'id');
    _requireText(name, 'name');
  }

  final String id;
  final String name;
  final String? imageUrl;
  final List<String> artistIds;

  factory MusicTrack.fromJson(Map<String, dynamic> json) => MusicTrack(
    id: json['id'] as String,
    name: json['name'] as String,
    imageUrl: json['imageUrl'] as String?,
    artistIds: (json['artistIds'] as List? ?? []).cast<String>(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'artistIds': artistIds,
  };
}

class MusicProfile {
  MusicProfile({
    required this.userId,
    Iterable<MusicArtist> artists = const [],
    Iterable<MusicTrack> tracks = const [],
    Iterable<String> genres = const [],
    required DateTime syncedAt,
  }) : artists = List.unmodifiable({for (final a in artists) a.id: a}.values),
       tracks = List.unmodifiable({for (final t in tracks) t.id: t}.values),
       genres = normalizeGenres(genres),
       syncedAt = syncedAt.toUtc() {
    _requireText(userId, 'userId');
  }

  /// LOVIC/Supabase user ID, never the Spotify user ID.
  final String userId;
  final List<MusicArtist> artists;
  final List<MusicTrack> tracks;
  final List<String> genres;
  final DateTime syncedAt;

  bool get isEmpty => artists.isEmpty && tracks.isEmpty && genres.isEmpty;

  factory MusicProfile.fromJson(Map<String, dynamic> json) => MusicProfile(
    userId: json['userId'] as String,
    artists: (json['artists'] as List).map(
      (item) => MusicArtist.fromJson(Map<String, dynamic>.from(item as Map)),
    ),
    tracks: (json['tracks'] as List).map(
      (item) => MusicTrack.fromJson(Map<String, dynamic>.from(item as Map)),
    ),
    genres: (json['genres'] as List).cast<String>(),
    syncedAt: DateTime.parse(json['syncedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'artists': artists.map((a) => a.toJson()).toList(),
    'tracks': tracks.map((t) => t.toJson()).toList(),
    'genres': genres,
    'syncedAt': syncedAt.toIso8601String(),
  };
}

/// Keep Spotify genre vocabulary; normalize case/spacing, discard duplicates.
List<String> normalizeGenres(Iterable<String> genres) => List.unmodifiable(
  genres
      .map((g) => g.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' '))
      .where((g) => g.isNotEmpty)
      .toSet()
      .toList()
    ..sort(),
);

void _requireText(String value, String field) {
  if (value.trim().isEmpty) throw ArgumentError.value(value, field);
}
