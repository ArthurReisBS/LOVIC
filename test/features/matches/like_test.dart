import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lovic/features/matches/data/backend_a_like_data_source.dart';
import 'package:lovic/features/matches/data/backend_like_repository.dart';
import 'package:lovic/features/matches/domain/like_request.dart';
import 'package:lovic/features/matches/domain/like_repository.dart';
import 'package:lovic/features/matches/domain/like_result.dart';
import 'package:lovic/features/matches/domain/match_policy.dart';

void main() {
  group('configured threshold', () {
    final policy = MatchPolicy(highAffinityThreshold: 75);
    test('below, equal and above', () {
      expect(policy.isHighAffinity(74.99), isFalse);
      expect(policy.isHighAffinity(75), isTrue);
      expect(policy.isHighAffinity(75.01), isTrue);
    });
    test('rejects invalid threshold and scores', () {
      for (final value in [-1.0, 101.0, double.nan, double.infinity]) {
        expect(
          () => MatchPolicy(highAffinityThreshold: value),
          throwsArgumentError,
        );
        expect(() => policy.isHighAffinity(value), throwsArgumentError);
      }
    });
  });

  test(
    'normalizes unilateral, bilateral and high-affinity backend results',
    () {
      for (final reason in MatchReason.values) {
        final matched = reason != MatchReason.noMatch;
        final result = LikeResult.fromJson({
          'deuMatch': matched,
          'conversationId': matched ? 'conversation-a-b' : null,
          'reason': reason.code,
        });
        expect(result.deuMatch, matched);
        expect(result.reason, reason);
        expect(result.toJson().keys, ['deuMatch', 'conversationId', 'reason']);
      }
    },
  );

  test('rejects contradictory, unknown and malformed backend contracts', () {
    final invalid = <Map<String, Object?>>[
      {'deuMatch': true, 'conversationId': null, 'reason': 'mutual_like'},
      {'deuMatch': true, 'conversationId': ' ', 'reason': 'high_affinity'},
      {'deuMatch': true, 'conversationId': 'c', 'reason': 'no_match'},
      {'deuMatch': false, 'conversationId': 'c', 'reason': 'no_match'},
      {'deuMatch': false, 'conversationId': null, 'reason': 'mutual_like'},
      {'deuMatch': false, 'conversationId': null, 'reason': 'unknown'},
      {'deuMatch': 'false', 'conversationId': null, 'reason': 'no_match'},
      {'deuMatch': false, 'reason': 'no_match'},
    ];
    for (final json in invalid) {
      expect(() => LikeResult.fromJson(json), throwsFormatException);
    }
  });

  test('validates self-like, session and affinity before calling backend', () {
    final source = _ControlledSource();
    final repository = BackendLikeRepository(
      dataSource: source,
      currentUserId: () => 'actor',
    );
    expect(
      () => repository.like(targetUserId: 'actor', affinity: 50),
      throwsA(
        isA<LikeFailure>().having(
          (error) => error.code,
          'code',
          LikeFailureCode.invalidRequest,
        ),
      ),
    );
    expect(
      () => repository.like(targetUserId: ' actor ', affinity: 50),
      throwsA(isA<LikeFailure>()),
    );
    for (final score in [-1.0, 101.0, double.nan, double.infinity]) {
      expect(
        () => repository.like(targetUserId: 'b', affinity: score),
        throwsA(isA<LikeFailure>()),
      );
    }
    final unauthenticated = BackendLikeRepository(
      dataSource: source,
      currentUserId: () => null,
    );
    expect(
      () => unauthenticated.like(targetUserId: 'b', affinity: 50),
      throwsA(
        isA<LikeFailure>().having(
          (error) => error.code,
          'code',
          LikeFailureCode.sessionExpired,
        ),
      ),
    );
    expect(source.requests, isEmpty);
  });

  test(
    'double tap shares operation; backend owns persisted idempotency',
    () async {
      final source = _ControlledSource();
      final repository = BackendLikeRepository(
        dataSource: source,
        currentUserId: () => 'actor',
      );
      final first = repository.like(targetUserId: 'b', affinity: 100);
      final duplicate = repository.like(targetUserId: 'b', affinity: 100);
      expect(identical(first, duplicate), isTrue);
      await Future<void>.value();
      expect(source.requests, hasLength(1));
      expect(source.requests.single.actorUserId, 'actor');
      expect(source.requests.single.affinity, 100);
      final result = LikeResult(
        deuMatch: true,
        conversationId: 'same-conversation',
        reason: MatchReason.mutualLike,
      );
      source.pending.removeAt(0).complete(result);
      expect(await first, same(result));
      expect(await duplicate, same(result));
      final later = repository.like(targetUserId: 'b', affinity: 0);
      await Future<void>.value();
      expect(source.requests, hasLength(2));
      source.pending.removeAt(0).complete(result);
      expect((await later).conversationId, 'same-conversation');
    },
  );

  test('retry succeeds after a synchronous backend failure', () async {
    var calls = 0;
    final repository = BackendLikeRepository(
      currentUserId: () => 'actor',
      dataSource: BackendALikeOperationDataSource((request) {
        calls++;
        if (calls == 1) throw StateError('Sem conexão.');
        return Future.value({
          'deuMatch': false,
          'conversationId': null,
          'reason': 'no_match',
        });
      }),
    );
    await expectLater(
      repository.like(targetUserId: 'b', affinity: 50),
      throwsA(
        isA<LikeFailure>().having(
          (error) => error.code,
          'code',
          LikeFailureCode.unavailable,
        ),
      ),
    );
    expect(
      (await repository.like(targetUserId: 'b', affinity: 50)).deuMatch,
      isFalse,
    );
    expect(calls, 2);
  });
}

class _ControlledSource implements BackendALikeDataSource {
  final requests = <LikeRequest>[];
  final pending = <Completer<LikeResult>>[];

  @override
  Future<LikeResult> like(LikeRequest request) {
    requests.add(request);
    final completer = Completer<LikeResult>();
    pending.add(completer);
    return completer.future;
  }
}
