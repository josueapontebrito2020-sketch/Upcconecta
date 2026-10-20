import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/feed_section.dart';
import '../entities/post.dart';
import '../entities/post_category.dart';
import '../repositories/feed_repository.dart';

/// Publicaciones de un apartado del inicio, con filtro de categoría opcional.
class GetFeedPosts {
  const GetFeedPosts(this._repository);

  final FeedRepository _repository;

  Future<Result<List<Post>, DataFailure>> call({
    required FeedSection section,
    PostCategory? category,
  }) {
    return _repository.getPosts(section: section, category: category);
  }
}
