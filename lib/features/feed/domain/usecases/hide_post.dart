import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../repositories/feed_repository.dart';

/// Oculta una publicación del inicio del usuario actual.
class HidePost {
  const HidePost(this._repository);

  final FeedRepository _repository;

  Future<Result<void, DataFailure>> call(String postId) {
    return _repository.hidePost(postId);
  }
}
