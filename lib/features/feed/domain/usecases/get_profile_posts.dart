import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/post.dart';
import '../entities/post_list_source.dart';
import '../repositories/feed_repository.dart';

/// Publicaciones de una pestaña del perfil (propias, guardadas, me gusta o
/// compartidas).
class GetProfilePosts {
  const GetProfilePosts(this._repository);

  final FeedRepository _repository;

  Future<Result<List<Post>, DataFailure>> call({
    required String userId,
    required PostCollection collection,
  }) {
    return _repository.getProfilePosts(userId: userId, collection: collection);
  }
}
