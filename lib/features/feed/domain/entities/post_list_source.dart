import 'feed_section.dart';

/// Colecciones de publicaciones de un perfil (pestañas del perfil).
enum PostCollection {
  /// Las que publicó la persona.
  authored,

  /// Las que guardé (solo en mi perfil).
  saved,

  /// Las que me gustaron (solo en mi perfil).
  liked,

  /// Las que compartí (solo en mi perfil).
  shared,
}

/// De dónde sale una lista de publicaciones: un apartado del inicio o una
/// pestaña de un perfil. Se usa como llave del controlador de cada lista,
/// por eso compara por valor.
sealed class PostListSource {
  const PostListSource();
}

/// Destacados, Comunidad o Transporte (barra superior del inicio).
final class HomeFeedSource extends PostListSource {
  const HomeFeedSource(this.section);

  final FeedSection section;

  @override
  bool operator ==(Object other) =>
      other is HomeFeedSource && other.section == section;

  @override
  int get hashCode => section.hashCode;
}

/// Una pestaña del perfil de [userId].
final class ProfilePostsSource extends PostListSource {
  const ProfilePostsSource({required this.userId, required this.collection});

  final String userId;
  final PostCollection collection;

  @override
  bool operator ==(Object other) =>
      other is ProfilePostsSource &&
      other.userId == userId &&
      other.collection == collection;

  @override
  int get hashCode => Object.hash(userId, collection);
}
