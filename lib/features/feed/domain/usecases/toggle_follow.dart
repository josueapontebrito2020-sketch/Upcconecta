import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../repositories/feed_repository.dart';

/// Empieza o deja de seguir al autor de una publicación.
class ToggleFollow {
  const ToggleFollow(this._repository);

  final FeedRepository _repository;

  Future<Result<void, DataFailure>> call(
    String authorId, {
    required bool following,
  }) {
    return _repository.setFollowing(authorId, following: following);
  }
}
