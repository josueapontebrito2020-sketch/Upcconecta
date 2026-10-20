import '../../domain/entities/post.dart';
import '../../domain/entities/post_author.dart';
import '../../domain/entities/post_category.dart';
import '../../domain/entities/post_media.dart';

/// Convierte una fila de la vista `feed_posts` de Supabase en un [Post].
///
/// [publicUrl] arma la dirección pública de un archivo del bucket a partir
/// de su ruta (`storage_path`).
Post postFromFeedRow(
  Map<String, dynamic> row, {
  required String Function(String path) publicUrl,
}) {
  final media = <PostMedia>[
    for (final item in (row['media'] as List<dynamic>? ?? const []))
      if (item is Map && item['path'] is String)
        PostMedia(
          url: publicUrl(item['path'] as String),
          type: item['type'] == 'video'
              ? PostMediaType.video
              : PostMediaType.image,
        ),
  ];

  return Post(
    id: row['id'] as String,
    author: PostAuthor(
      id: row['author_id'] as String,
      username: (row['author_username'] as String?) ?? '',
      fullName: (row['author_full_name'] as String?) ?? '',
      avatarUrl: row['author_avatar_url'] as String?,
      isVerified: row['author_is_verified'] == true,
    ),
    text: (row['content'] as String?) ?? '',
    category: _categoryFrom(row['category']),
    createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
    media: media,
    tags: [
      for (final tag in (row['tags'] as List<dynamic>? ?? const []))
        if (tag is String) tag,
    ],
    ratingAverage: _toDouble(row['rating_avg']),
    reviewCount: _toInt(row['rating_count']),
    isFeatured: row['is_featured'] == true,
    likeCount: _toInt(row['like_count']),
    saveCount: _toInt(row['save_count']),
    shareCount: _toInt(row['share_count']),
    isLiked: row['is_liked'] == true,
    isSaved: row['is_saved'] == true,
    isFollowingAuthor: row['is_following_author'] == true,
    isMine: row['is_mine'] == true,
  );
}

/// Nombre de la categoría en la base de datos (columna `posts.category`).
String categoryToDb(PostCategory category) => category.name;

PostCategory _categoryFrom(Object? value) {
  for (final category in PostCategory.values) {
    if (category.name == value) return category;
  }
  return PostCategory.product;
}

int _toInt(Object? value) => switch (value) {
  final num number => number.toInt(),
  final String text => int.tryParse(text) ?? 0,
  _ => 0,
};

double _toDouble(Object? value) => switch (value) {
  final num number => number.toDouble(),
  final String text => double.tryParse(text) ?? 0,
  _ => 0,
};
