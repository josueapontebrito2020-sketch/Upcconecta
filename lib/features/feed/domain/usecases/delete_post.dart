import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../repositories/feed_repository.dart';

/// Borra una publicación propia.
class DeletePost {
  const DeletePost(this._repository);

  final FeedRepository _repository;

  Future<Result<void, DataFailure>> call(String postId) {
    return _repository.deletePost(postId);
  }
}
