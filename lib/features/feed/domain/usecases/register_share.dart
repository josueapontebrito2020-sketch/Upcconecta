import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../repositories/feed_repository.dart';

/// Cuenta que alguien compartió la publicación.
class RegisterShare {
  const RegisterShare(this._repository);

  final FeedRepository _repository;

  Future<Result<void, DataFailure>> call(String postId) {
    return _repository.registerShare(postId);
  }
}
