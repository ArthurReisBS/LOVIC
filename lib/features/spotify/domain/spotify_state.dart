import '../../music_profile/domain/music_profile.dart';

enum SpotifyConnectionStatus { connected, notConnected, expired }

enum SpotifyFailureCode {
  notConfigured,
  notConnected,
  expired,
  cancelled,
  invalidCallback,
  rateLimited,
  unavailable,
  invalidData,
  storageUnavailable,
  forbidden,
}

/// Safe domain error. Never includes HTTP response bodies, URLs or tokens.
class SpotifyFailure implements Exception {
  const SpotifyFailure(this.code, {this.retryAt});

  final SpotifyFailureCode code;
  final DateTime? retryAt;

  String get message => switch (code) {
    SpotifyFailureCode.notConfigured =>
      'A conexão com Spotify ainda não está disponível.',
    SpotifyFailureCode.notConnected =>
      'Conecte seu Spotify para sincronizar seu perfil musical.',
    SpotifyFailureCode.expired =>
      'Sua conexão com Spotify expirou. Conecte novamente.',
    SpotifyFailureCode.cancelled => 'A conexão com Spotify foi cancelada.',
    SpotifyFailureCode.invalidCallback =>
      'Não foi possível confirmar a conexão. Tente novamente.',
    SpotifyFailureCode.rateLimited =>
      'O Spotify está recebendo muitas solicitações. Tente mais tarde.',
    SpotifyFailureCode.unavailable =>
      'Não foi possível acessar o Spotify agora. Tente novamente.',
    SpotifyFailureCode.invalidData =>
      'Não foi possível atualizar seu perfil musical agora.',
    SpotifyFailureCode.storageUnavailable =>
      'Não foi possível salvar seus dados musicais agora.',
    SpotifyFailureCode.forbidden =>
      'O Spotify não autorizou o acesso. Reconecte sua conta.',
  };

  @override
  String toString() => 'SpotifyFailure(${code.name})';
}

class SpotifyProfileState {
  const SpotifyProfileState({
    required this.status,
    this.profile,
    this.isLoading = false,
    this.isCached = false,
    this.failure,
  });

  final SpotifyConnectionStatus status;
  final MusicProfile? profile;
  final bool isLoading;
  final bool isCached;
  final SpotifyFailure? failure;

  bool get isEmpty => profile == null || profile!.isEmpty;
  bool get canReconnect => status != SpotifyConnectionStatus.connected;
}
