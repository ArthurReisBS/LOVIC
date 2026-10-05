import 'package:geolocator/geolocator.dart';

import '../domain/location_repository.dart';

/// Leitura sob demanda e somente em foreground. A permissão pertence à UI.
class GeolocatorLocationDataSource implements OwnLocationDataSource {
  final Duration readTimeout;

  const GeolocatorLocationDataSource({
    this.readTimeout = const Duration(seconds: 20),
  });

  @override
  Future<OwnPosition> readOwnPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationReadException(LocationStatus.serviceDisabled);
      }
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw const LocationReadException(LocationStatus.permissionDenied);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: readTimeout,
        ),
      );
      return OwnPosition(
        latitude: position.latitude,
        longitude: position.longitude,
        capturedAt: position.timestamp.toUtc(),
      );
    } on LocationReadException {
      rethrow;
    } on PermissionDeniedException {
      throw const LocationReadException(LocationStatus.permissionDenied);
    } on LocationServiceDisabledException {
      throw const LocationReadException(LocationStatus.serviceDisabled);
    } catch (_) {
      throw const LocationReadException(LocationStatus.readFailed);
    }
  }
}
