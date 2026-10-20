import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/feed_section.dart';
import '../entities/new_post.dart';
import '../entities/post.dart';
import '../entities/post_category.dart';
import '../entities/post_list_source.dart';
import '../entities/report_reason.dart';

/// Contrato del inicio (feed). La capa `data` lo implementa con Supabase o
/// con datos de prueba; la interfaz no sabe cuál se usa.
abstract interface class FeedRepository {
  /// Publicaciones de un apartado, de la más nueva a la más vieja.
  /// Si [category] no es null, solo las de esa categoría.
  Future<Result<List<Post>, DataFailure>> getPosts({
    required FeedSection section,
    PostCategory? category,
  });

  /// Publicaciones de una pestaña del perfil de [userId], de la más
  /// reciente a la más vieja (guardadas, me gusta y compartidas: por la fecha
  /// en que se hizo).
  Future<Result<List<Post>, DataFailure>> getProfilePosts({
    required String userId,
    required PostCollection collection,
  });

  /// Sube los archivos y crea la publicación. Devuelve su id.
  Future<Result<String, DataFailure>> createPost(NewPost post);

  /// Borra una publicación propia y sus archivos.
  Future<Result<void, DataFailure>> deletePost(String postId);

  Future<Result<void, DataFailure>> setLiked(String postId, {required bool liked});

  Future<Result<void, DataFailure>> setSaved(String postId, {required bool saved});

  Future<Result<void, DataFailure>> setFollowing(
    String authorId, {
    required bool following,
  });

  /// Suma una vez al contador de compartidos.
  Future<Result<void, DataFailure>> registerShare(String postId);

  /// Deja de mostrar la publicación a este usuario.
  Future<Result<void, DataFailure>> hidePost(String postId);

  Future<Result<void, DataFailure>> reportPost(
    String postId,
    ReportReason reason,
  );
}
