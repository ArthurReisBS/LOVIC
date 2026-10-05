import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lovic/features/location/domain/location_repository.dart';

class FakeLocationSource implements OwnLocationDataSource {
  int reads = 0;
  LocationStatus? failure;
  Completer<OwnPosition>? pending;

  @override
  Future<OwnPosition> readOwnPosition() async {
    reads++;
    if (failure != null) throw LocationReadException(failure!);
    if (pending != null) return pending!.future;
    return OwnPosition(
      latitude: -23.5,
      longitude: -46.6,
      capturedAt: DateTime.utc(2026),
    );
  }
}

class FakeLocationWriter implements OwnLocationWriter {
  int writes = 0;
  bool fails = false;

  @override
  Future<void> saveOwnPosition(OwnPosition position) async {
    writes++;
    if (fails) throw StateError('network');
  }
}

void main() {
  late FakeLocationSource source;
  late FakeLocationWriter writer;
  late DateTime now;
  late LocationRepository repository;

  setUp(() {
    source = FakeLocationSource();
    writer = FakeLocationWriter();
    now = DateTime.utc(2026, 10, 5, 12);
    repository = LocationRepository(
      dataSource: source,
      writer: writer,
      now: () => now,
    );
  });

  test(
    'UI sem consentimento impede qualquer leitura/envio de posição',
    () async {
      final result = await repository.updateOwnLocation(
        permissionGranted: false,
      );
      expect(result.status, LocationStatus.permissionDenied);
      expect(source.reads, 0);
      expect(writer.writes, 0);
    },
  );

  test(
    'primeira descoberta envia; voltar antes de 15 min não relê GPS',
    () async {
      final first = await repository.updateOwnLocation(permissionGranted: true);
      expect(first.status, LocationStatus.updated);
      expect(first.nextUpdateAt, now.add(const Duration(minutes: 15)));
      now = now.add(const Duration(minutes: 14, seconds: 59));
      final throttled = await repository.updateOwnLocation(
        permissionGranted: true,
      );
      expect(throttled.status, LocationStatus.throttled);
      expect(source.reads, 1);
      now = now.add(const Duration(seconds: 1));
      expect(
        (await repository.updateOwnLocation(permissionGranted: true)).status,
        LocationStatus.updated,
      );
      expect(writer.writes, 2);
    },
  );

  test('intervalo é configurável em um único lugar', () async {
    repository = LocationRepository(
      dataSource: source,
      writer: writer,
      now: () => now,
      policy: LocationUpdatePolicy(minimumInterval: const Duration(minutes: 2)),
    );
    await repository.updateOwnLocation(permissionGranted: true);
    now = now.add(const Duration(minutes: 2));
    await repository.updateOwnLocation(permissionGranted: true);
    expect(writer.writes, 2);
    expect(
      () => LocationUpdatePolicy(minimumInterval: Duration.zero),
      throwsArgumentError,
    );
  });

  for (final failure in [
    LocationStatus.permissionDenied,
    LocationStatus.serviceDisabled,
    LocationStatus.readFailed,
  ]) {
    test('estado $failure não envia coordenadas', () async {
      source.failure = failure;
      final result = await repository.updateOwnLocation(
        permissionGranted: true,
      );
      expect(result.status, failure);
      expect(writer.writes, 0);
    });
  }

  test('falha de rede permite nova tentativa imediatamente', () async {
    writer.fails = true;
    expect(
      (await repository.updateOwnLocation(permissionGranted: true)).status,
      LocationStatus.networkError,
    );
    writer.fails = false;
    expect(
      (await repository.updateOwnLocation(permissionGranted: true)).status,
      LocationStatus.updated,
    );
    expect(writer.writes, 2);
  });

  test('chamadas simultâneas compartilham leitura e envio únicos', () async {
    source.pending = Completer<OwnPosition>();
    final first = repository.updateOwnLocation(permissionGranted: true);
    final second = repository.updateOwnLocation(permissionGranted: true);
    source.pending!.complete(
      OwnPosition(latitude: 0, longitude: 0, capturedAt: now),
    );
    final results = await Future.wait([first, second]);
    expect(
      results.every((result) => result.status == LocationStatus.updated),
      isTrue,
    );
    expect(source.reads, 1);
    expect(writer.writes, 1);
  });

  test('logout invalida leitura pendente antes de escrever', () async {
    source.pending = Completer<OwnPosition>();
    final pending = repository.updateOwnLocation(permissionGranted: true);

    repository.dispose();
    source.pending!.complete(
      OwnPosition(latitude: 0, longitude: 0, capturedAt: now),
    );

    expect((await pending).status, LocationStatus.cancelled);
    expect(writer.writes, 0);
    expect(
      (await repository.updateOwnLocation(permissionGranted: true)).status,
      LocationStatus.cancelled,
    );
  });

  test('posição valida limites e representação de log omite coordenadas', () {
    expect(
      () => OwnPosition(latitude: 91, longitude: 0, capturedAt: now),
      throwsArgumentError,
    );
    expect(
      () => OwnPosition(latitude: 0, longitude: double.nan, capturedAt: now),
      throwsArgumentError,
    );
    final own = OwnPosition(latitude: -23.5, longitude: -46.6, capturedAt: now);
    expect(own.toString(), isNot(contains('-23.5')));
    expect(own.toString(), isNot(contains('-46.6')));
  });
}
