import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../repositories/feed_repository.dart';

/// Guarda una publicación (para verla después) o la quita de guardados.
class ToggleSave {
  const ToggleSave(this._repository);

  final FeedRepository _repository;

  Future<Result<void, DataFailure>> call(String postId, {required bool saved}) {
    return _repository.setSaved(postId, saved: saved);
  }
}
