/// Autor de una publicación, con los datos que se muestran en la tarjeta.
class PostAuthor {
  const PostAuthor({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.isVerified = false,
  });

  final String id;
  final String username;
  final String fullName;
  final String? avatarUrl;

  /// Tiene la insignia de verificado (pagada).
  final bool isVerified;
}
