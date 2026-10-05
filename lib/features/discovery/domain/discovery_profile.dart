import '../../music_profile/domain/music_profile.dart';

/// Entrada do Backend A: distância segura já calculada/arredondada no banco.
/// Não contém latitude/longitude ou qualquer posição de terceiros.
class DiscoveryCandidate {
  final String id;
  final String name;
  final int age;
  final String bio;
  final String? photoUrl;
  final MusicProfile musicProfile;
  final double distanceKm;

  DiscoveryCandidate({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.musicProfile,
    required this.distanceKm,
    this.photoUrl,
  }) {
    if (id.trim().isEmpty || musicProfile.userId != id) {
      throw ArgumentError('O perfil musical deve pertencer ao candidato.');
    }
    if (age < 0) throw ArgumentError.value(age, 'age');
    if (!distanceKm.isFinite || distanceKm < 0) {
      throw ArgumentError.value(distanceKm, 'distanceKm');
    }
  }
}

/// Dados prontos para card e perfil completo; telas não recalculam regras.
class DiscoveryProfile {
  final DiscoveryCandidate candidate;
  final double affinity;
  final double rankingScore;

  const DiscoveryProfile({
    required this.candidate,
    required this.affinity,
    required this.rankingScore,
  });

  String get id => candidate.id;
  String get name => candidate.name;
  int get age => candidate.age;
  String get bio => candidate.bio;
  String? get photoUrl => candidate.photoUrl;
  double get distanceKm => candidate.distanceKm;
  MusicProfile get musicProfile => candidate.musicProfile;
  List<String> get genres => musicProfile.genres;
  List<MusicArtist> get artists => musicProfile.artists;
  List<MusicTrack> get tracks => musicProfile.tracks;
}
