import '../domain/like_request.dart';
import '../domain/like_result.dart';

/// Arthur owns the authenticated, atomic backend operation. It must persist the
/// like, apply the configured match rule and return/create exactly one
/// conversation per pair. The server must validate auth and affinity itself.
abstract interface class BackendALikeDataSource {
  Future<LikeResult> like(LikeRequest request);
}

typedef BackendALikeOperation =
    Future<Map<String, Object?>> Function(LikeRequest request);

/// Connect Arthur's real Supabase operation here; no fallback or production fake.
/// The operation translates his RPC's parameters/response to the public contract.
class BackendALikeOperationDataSource implements BackendALikeDataSource {
  const BackendALikeOperationDataSource(this.operation);

  final BackendALikeOperation operation;

  @override
  Future<LikeResult> like(LikeRequest request) async =>
      LikeResult.fromJson(await operation(request));
}
