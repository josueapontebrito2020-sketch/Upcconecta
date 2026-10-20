import 'post_author.dart';
import 'post_category.dart';
import 'post_media.dart';

/// Publicación del inicio: un producto, servicio, habilidad o asesoría.
///
/// Incluye lo que el usuario actual hizo con ella ([isLiked], [isSaved],
/// [isFollowingAuthor]) para pintar los botones sin otra consulta.
class Post {
  const Post({
    required this.id,
    required this.author,
    required this.text,
    required this.category,
    required this.createdAt,
    this.media = const [],
    this.tags = const [],
    this.ratingAverage = 0,
    this.reviewCount = 0,
    this.isFeatured = false,
    this.likeCount = 0,
    this.saveCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.isFollowingAuthor = false,
    this.isMine = false,
  });

  final String id;
  final PostAuthor author;
  final String text;
  final PostCategory category;
  final DateTime createdAt;
  final List<PostMedia> media;
  final List<String> tags;

  /// Promedio de estrellas (0 a 5) de quienes contrataron.
  final double ratingAverage;
  final int reviewCount;

  /// Publicación destacada (pagada).
  final bool isFeatured;

  final int likeCount;

  /// Cuántas personas la guardaron y cuántas veces se compartió.
  final int saveCount;
  final int shareCount;

  final bool isLiked;
  final bool isSaved;
  final bool isFollowingAuthor;

  /// La publicó el usuario actual (puede borrarla, no puede seguirse).
  final bool isMine;

  bool get hasRatings => reviewCount > 0;

  Post copyWith({
    int? likeCount,
    int? saveCount,
    int? shareCount,
    bool? isLiked,
    bool? isSaved,
    bool? isFollowingAuthor,
  }) {
    return Post(
      id: id,
      author: author,
      text: text,
      category: category,
      createdAt: createdAt,
      media: media,
      tags: tags,
      ratingAverage: ratingAverage,
      reviewCount: reviewCount,
      isFeatured: isFeatured,
      likeCount: likeCount ?? this.likeCount,
      saveCount: saveCount ?? this.saveCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isFollowingAuthor: isFollowingAuthor ?? this.isFollowingAuthor,
      isMine: isMine,
    );
  }
}
