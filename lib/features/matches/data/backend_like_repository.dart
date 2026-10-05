import '../domain/like_repository.dart';
import '../domain/like_request.dart';
import '../domain/like_result.dart';
import 'backend_a_like_data_source.dart';

typedef AuthenticatedUserId = String? Function();

class BackendLikeRepository implements LikeRepository {
  BackendLikeRepository({
    required BackendALikeDataSource dataSource,
    required AuthenticatedUserId currentUserId,
  }) : _dataSource = dataSource,
       _currentUserId = currentUserId;

  final BackendALikeDataSource _dataSource;
  final AuthenticatedUserId _currentUserId;
  final Map<(String, String), Future<LikeResult>> _pending = {};

  @override
  Future<LikeResult> like({
    required String targetUserId,
    required double affinity,
  }) {
    final actorUserId = _currentUserId();
    if (actorUserId == null || actorUserId.trim().isEmpty) {
      throw const LikeFailure(LikeFailureCode.sessionExpired);
    }
    late final LikeRequest request;
    try {
      request = LikeRequest(
        actorUserId: actorUserId,
        targetUserId: targetUserId,
        affinity: affinity,
      );
    } on ArgumentError {
      throw const LikeFailure(LikeFailureCode.invalidRequest);
    }
    final key = (actorUserId, targetUserId);
    // A double tap shares one operation. Persistent idempotency belongs to A.
    return _pending.putIfAbsent(key, () => _send(key, request));
  }

  Future<LikeResult> _send((String, String) key, LikeRequest request) async {
    // Start after putIfAbsent has registered the future, even if A throws
    // synchronously, so failed requests never leave a stale pending entry.
    await Future<void>.value();
    try {
      return await _dataSource.like(request);
    } on LikeFailure {
      rethrow;
    } on FormatException {
      throw const LikeFailure(LikeFailureCode.invalidResponse);
    } catch (_) {
      throw const LikeFailure(LikeFailureCode.unavailable);
    } finally {
      _pending.remove(key);
    }
  }
}
