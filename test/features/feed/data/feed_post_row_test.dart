import 'package:flutter_test/flutter_test.dart';
import 'package:upcconect/features/feed/data/models/feed_post_row.dart';
import 'package:upcconect/features/feed/domain/entities/post_category.dart';

void main() {
  test('convierte una fila de feed_posts en una publicación', () {
    final post = postFromFeedRow(
      {
        'id': 'p1',
        'author_id': 'u1',
        'author_username': 'ana',
        'author_full_name': 'Ana Gómez',
        'author_avatar_url': null,
        'author_is_verified': true,
        'content': 'Vendo libros',
        'category': 'product',
        'tags': ['Libros'],
        'is_featured': true,
        'like_count': 3,
        'save_count': 1,
        'share_count': 0,
        'rating_avg': '4.50',
        'rating_count': 2,
        'created_at': '2026-10-20T10:00:00+00:00',
        'media': [
          {'path': 'u1/abc/0.jpg', 'type': 'image'},
          {'path': 'u1/abc/1.mp4', 'type': 'video'},
        ],
        'is_mine': false,
        'is_liked': true,
        'is_saved': false,
        'is_following_author': true,
      },
      publicUrl: (path) => 'https://archivos/$path',
    );

    expect(post.author.fullName, 'Ana Gómez');
    expect(post.author.isVerified, isTrue);
    expect(post.category, PostCategory.product);
    expect(post.ratingAverage, 4.5);
    expect(post.media.first.url, 'https://archivos/u1/abc/0.jpg');
    expect(post.media.last.isVideo, isTrue);
    expect(post.isLiked, isTrue);
    expect(post.isFollowingAuthor, isTrue);
    expect(post.isMine, isFalse);
  });
}
