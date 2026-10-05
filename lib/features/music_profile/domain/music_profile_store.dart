import 'music_profile.dart';

/// Backend A implements persistence/authorized reads. No table names are assumed.
abstract interface class MusicProfileStore {
  Future<MusicProfile?> read(String userId);
  Future<void> write(MusicProfile profile);
}

/// Real session cache, scoped by LOVIC user. Optional durable store is injected.
class MemoryMusicProfileStore implements MusicProfileStore {
  final Map<String, MusicProfile> _profiles = {};

  @override
  Future<MusicProfile?> read(String userId) async => _profiles[userId];

  @override
  Future<void> write(MusicProfile profile) async {
    _profiles[profile.userId] = profile;
  }
}
