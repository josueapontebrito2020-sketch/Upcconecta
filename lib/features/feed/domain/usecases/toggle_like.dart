import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../repositories/feed_repository.dart';

/// Da o quita "me gusta" a una publicación.
class ToggleLike {
  const ToggleLike(this._repository);

  final FeedRepository _repository;

  Future<Result<void, DataFailure>> call(String postId, {required bool liked}) {
    return _repository.setLiked(postId, liked: liked);
  }
}
