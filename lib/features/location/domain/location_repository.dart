/// Apenas a posição do dispositivo atual; nunca compõe um DiscoveryProfile.
class OwnPosition {
  final double latitude;
  final double longitude;
  final DateTime capturedAt;

  OwnPosition({
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
  }) {
    if (!latitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        !longitude.isFinite ||
        longitude < -180 ||
        longitude > 180) {
      throw ArgumentError('Posição inválida.');
    }
  }

  @override
  String toString() => 'OwnPosition(capturedAt: $capturedAt)';
}

enum LocationStatus {
  updated,
  throttled,
  permissionDenied,
  serviceDisabled,
  readFailed,
  networkError,
  cancelled,
}

class LocationReadException implements Exception {
  final LocationStatus status;
  const LocationReadException(this.status);
}

abstract interface class OwnLocationDataSource {
  /// Confere permissão/serviço novamente; jamais solicita permissão à UI.
  Future<OwnPosition> readOwnPosition();
}

/// Arthur implementa uma escrita autenticada somente da posição do dono.
/// Sem argumento de userId: a sessão do Supabase define o proprietário.
abstract interface class OwnLocationWriter {
  /// Deve ficar vinculado à sessão que criou este objeto e rejeitar a escrita
  /// se essa sessão tiver sido encerrada ou trocada.
  Future<void> saveOwnPosition(OwnPosition position);
}

class LocationUpdatePolicy {
  final Duration minimumInterval;

  /// Fallback de 15 min da arquitetura; configurável, não é regra imutável.
  LocationUpdatePolicy({this.minimumInterval = const Duration(minutes: 15)}) {
    if (minimumInterval <= Duration.zero) {
      throw ArgumentError.value(minimumInterval, 'minimumInterval');
    }
  }
}

class LocationUpdateResult {
  final LocationStatus status;
  final DateTime? updatedAt;
  final DateTime? nextUpdateAt;

  const LocationUpdateResult(this.status, {this.updatedAt, this.nextUpdateAt});
}

/// Ponto único de envio: chamar ao entrar/voltar à descoberta ou após consentir.
/// Não há timer de GPS, rastreamento em background ou coordenadas no resultado.
/// Deve ter escopo de sessão e ser descartado no logout/troca de conta.
class LocationRepository {
  final OwnLocationDataSource dataSource;
  final OwnLocationWriter writer;
  final LocationUpdatePolicy policy;
  final DateTime Function() _now;
  DateTime? _lastUpdate;
  Future<LocationUpdateResult>? _inFlight;
  var _generation = 0;
  var _disposed = false;

  LocationRepository({
    required this.dataSource,
    required this.writer,
    LocationUpdatePolicy? policy,
    DateTime Function()? now,
  }) : policy = policy ?? LocationUpdatePolicy(),
       _now = now ?? DateTime.now;

  Future<LocationUpdateResult> updateOwnLocation({
    required bool permissionGranted,
  }) {
    if (_disposed) {
      return Future.value(const LocationUpdateResult(LocationStatus.cancelled));
    }
    // O consentimento de Isabelle vem antes de qualquer acesso ao dispositivo.
    if (!permissionGranted) {
      return Future.value(
        const LocationUpdateResult(LocationStatus.permissionDenied),
      );
    }
    if (_inFlight != null) return _inFlight!;
    final lastUpdate = _lastUpdate;
    final next = lastUpdate?.add(policy.minimumInterval);
    if (next != null && _now().isBefore(next)) {
      return Future.value(
        LocationUpdateResult(
          LocationStatus.throttled,
          updatedAt: lastUpdate,
          nextUpdateAt: next,
        ),
      );
    }
    final operation = _update(_generation);
    _inFlight = operation;
    return operation.whenComplete(() => _inFlight = null);
  }

  Future<LocationUpdateResult> _update(int generation) async {
    final OwnPosition position;
    try {
      position = await dataSource.readOwnPosition();
    } on LocationReadException catch (error) {
      return LocationUpdateResult(error.status);
    } catch (_) {
      return const LocationUpdateResult(LocationStatus.readFailed);
    }
    if (_disposed || generation != _generation) {
      return const LocationUpdateResult(LocationStatus.cancelled);
    }
    try {
      await writer.saveOwnPosition(position);
    } catch (_) {
      // Um envio falho não avança o throttle; é possível tentar novamente.
      return const LocationUpdateResult(LocationStatus.networkError);
    }
    if (_disposed || generation != _generation) {
      return const LocationUpdateResult(LocationStatus.cancelled);
    }
    _lastUpdate = _now().toUtc();
    return LocationUpdateResult(
      LocationStatus.updated,
      updatedAt: _lastUpdate,
      nextUpdateAt: _lastUpdate!.add(policy.minimumInterval),
    );
  }

  /// Invalida leituras pendentes ao encerrar ou trocar a sessão.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _generation++;
  }
}
