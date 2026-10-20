import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/new_post.dart';
import '../repositories/feed_repository.dart';

/// Publica en el inicio. Limpia el texto y las etiquetas (sin espacios de
/// sobra ni repetidas) antes de enviarlas.
class CreatePost {
  const CreatePost(this._repository);

  final FeedRepository _repository;

  Future<Result<String, DataFailure>> call(NewPost post) {
    return _repository.createPost(
      NewPost(
        text: post.text.trim(),
        category: post.category,
        tags: cleanTags(post.tags),
        media: post.media,
      ),
    );
  }

  /// Quita espacios, vacías y repetidas (sin importar mayúsculas), y deja
  /// máximo [AppConstants.postMaxTags].
  static List<String> cleanTags(List<String> tags) {
    final seen = <String>{};
    final clean = <String>[];
    for (final raw in tags) {
      var tag = raw.trim().replaceAll(RegExp(r'^#+'), '');
      if (tag.length > AppConstants.postMaxTagLength) {
        tag = tag.substring(0, AppConstants.postMaxTagLength);
      }
      if (tag.isEmpty || !seen.add(tag.toLowerCase())) continue;
      clean.add(tag);
      if (clean.length == AppConstants.postMaxTags) break;
    }
    return clean;
  }
}
