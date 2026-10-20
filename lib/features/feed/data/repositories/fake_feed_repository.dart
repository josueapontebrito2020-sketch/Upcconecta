import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/feed_section.dart';
import '../../domain/entities/new_post.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/post_author.dart';
import '../../domain/entities/post_category.dart';
import '../../domain/entities/post_list_source.dart';
import '../../domain/entities/post_media.dart';
import '../../domain/entities/report_reason.dart';
import '../../domain/repositories/feed_repository.dart';

/// Inicio con publicaciones de prueba, guardadas en memoria.
///
/// Se usa cuando la app corre sin claves de Supabase y en las pruebas. Los "me gusta", guardados, seguidos y ocultos se recuerdan
/// mientras la app esté abierta. Las fotos son de ejemplo (picsum.photos).
class FakeFeedRepository implements FeedRepository {
  FakeFeedRepository({this.latency = const Duration(milliseconds: 600)})
    : _posts = _samplePosts(DateTime.now());

  /// Espera simulada de la red.
  final Duration latency;

  final List<Post> _posts;
  final Set<String> _liked = {};
  final Set<String> _saved = {};
  final Set<String> _following = {};
  final Set<String> _hidden = {};
  final Map<String, int> _extraShares = {};

  @override
  Future<Result<List<Post>, DataFailure>> getPosts({
    required FeedSection section,
    PostCategory? category,
  }) async {
    await Future<void>.delayed(latency);
    if (section == FeedSection.transport) return const Ok([]);

    final posts = [
      for (final post in _posts)
        if (!_hidden.contains(post.id) &&
            (section != FeedSection.featured || post.isFeatured) &&
            (category == null || post.category == category))
          _withUserState(post),
    ];
    return Ok(posts);
  }

  Post _withUserState(Post post) {
    final liked = _liked.contains(post.id);
    final saved = _saved.contains(post.id);
    return post.copyWith(
      isLiked: liked,
      likeCount: post.likeCount + (liked ? 1 : 0),
      isSaved: saved,
      saveCount: post.saveCount + (saved ? 1 : 0),
      shareCount: post.shareCount + (_extraShares[post.id] ?? 0),
      isFollowingAuthor: _following.contains(post.author.id),
    );
  }

  @override
  Future<Result<List<Post>, DataFailure>> getProfilePosts({
    required String userId,
    required PostCollection collection,
  }) async {
    await Future<void>.delayed(latency);
    final Set<String>? ids = switch (collection) {
      PostCollection.authored => null,
      PostCollection.saved => _saved,
      PostCollection.liked => _liked,
      PostCollection.shared => _extraShares.keys.toSet(),
    };
    return Ok([
      for (final post in _posts)
        if (ids == null ? post.author.id == userId : ids.contains(post.id))
          _withUserState(post),
    ]);
  }

  /// Autor de lo que se publica en modo de prueba (la cuenta demo de
  /// `FakeAuthRepository`).
  static const PostAuthor _me = PostAuthor(
    id: 'demo',
    username: 'demo',
    fullName: 'Estudiante (prueba)',
  );

  int _nextId = 1;

  @override
  Future<Result<String, DataFailure>> createPost(NewPost post) async {
    await Future<void>.delayed(latency);
    final id = 'nuevo-${_nextId++}';
    _posts.insert(
      0,
      Post(
        id: id,
        author: _me,
        text: post.text,
        category: post.category,
        tags: post.tags,
        createdAt: DateTime.now(),
        isMine: true,
        media: [
          for (final file in post.media)
            PostMedia(
              url: '',
              bytes: file.isVideo ? null : file.bytes,
              type: file.isVideo ? PostMediaType.video : PostMediaType.image,
            ),
        ],
      ),
    );
    return Ok(id);
  }

  @override
  Future<Result<void, DataFailure>> deletePost(String postId) async {
    await Future<void>.delayed(latency ~/ 3);
    _posts.removeWhere((post) => post.id == postId);
    return const Ok(null);
  }

  @override
  Future<Result<void, DataFailure>> setLiked(
    String postId, {
    required bool liked,
  }) async {
    await Future<void>.delayed(latency ~/ 3);
    liked ? _liked.add(postId) : _liked.remove(postId);
    return const Ok(null);
  }

  @override
  Future<Result<void, DataFailure>> setSaved(
    String postId, {
    required bool saved,
  }) async {
    await Future<void>.delayed(latency ~/ 3);
    saved ? _saved.add(postId) : _saved.remove(postId);
    return const Ok(null);
  }

  @override
  Future<Result<void, DataFailure>> setFollowing(
    String authorId, {
    required bool following,
  }) async {
    await Future<void>.delayed(latency ~/ 3);
    following ? _following.add(authorId) : _following.remove(authorId);
    return const Ok(null);
  }

  @override
  Future<Result<void, DataFailure>> registerShare(String postId) async {
    await Future<void>.delayed(latency ~/ 3);
    _extraShares.update(postId, (count) => count + 1, ifAbsent: () => 1);
    return const Ok(null);
  }

  @override
  Future<Result<void, DataFailure>> hidePost(String postId) async {
    await Future<void>.delayed(latency ~/ 3);
    _hidden.add(postId);
    return const Ok(null);
  }

  @override
  Future<Result<void, DataFailure>> reportPost(
    String postId,
    ReportReason reason,
  ) async {
    await Future<void>.delayed(latency ~/ 3);
    return const Ok(null);
  }

  static String _photo(String seed) =>
      'https://picsum.photos/seed/upcconecta-$seed/800/600';

  static List<Post> _samplePosts(DateTime now) {
    const valentina = PostAuthor(
      id: 'u1',
      username: 'vale.rios',
      fullName: 'Valentina Ríos',
      isVerified: true,
    );
    const andres = PostAuthor(
      id: 'u2',
      username: 'andres.dev',
      fullName: 'Andrés Mejía',
      isVerified: true,
    );
    const laura = PostAuthor(
      id: 'u3',
      username: 'lau.tutorias',
      fullName: 'Laura Pérez',
    );
    const camilo = PostAuthor(
      id: 'u4',
      username: 'camilo.music',
      fullName: 'Camilo Torres',
    );
    const mariana = PostAuthor(
      id: 'u5',
      username: 'mari.postres',
      fullName: 'Mariana Gutiérrez',
      isVerified: true,
    );
    const sebastian = PostAuthor(
      id: 'u6',
      username: 'sebas.design',
      fullName: 'Sebastián Daza',
    );

    return [
      Post(
        id: 'p1',
        author: andres,
        text:
            'Te armo la página web o la app de tu emprendimiento 💻. Soy '
            'estudiante de Ingeniería de Sistemas y manejo Flutter, React y '
            'bases de datos. Precios de estudiante y entrega por etapas para '
            'que veas el avance. ¡Escríbeme y cotizamos sin compromiso!',
        category: PostCategory.service,
        tags: const ['Tecnología', 'Programación'],
        media: [PostMedia(url: _photo('web'), type: PostMediaType.image)],
        ratingAverage: 4.8,
        reviewCount: 23,
        isFeatured: true,
        likeCount: 128,
        saveCount: 40,
        shareCount: 12,
        createdAt: now.subtract(const Duration(minutes: 25)),
      ),
      Post(
        id: 'p2',
        author: valentina,
        text:
            'Vendo calculadora científica casi nueva, ideal para Cálculo y '
            'Física. Entrego en el campus.',
        category: PostCategory.product,
        tags: const ['Tecnología', 'Útiles'],
        media: [PostMedia(url: _photo('calculadora'), type: PostMediaType.image)],
        ratingAverage: 3.5,
        reviewCount: 4,
        likeCount: 17,
        saveCount: 3,
        shareCount: 1,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Post(
        id: 'p3',
        author: mariana,
        text:
            'Postres caseros por encargo 🍰: brownies, cheesecake y tres '
            'leches. Entrego en la cafetería central de lunes a viernes.',
        category: PostCategory.product,
        tags: const ['Comida', 'Postres'],
        media: [
          PostMedia(url: _photo('postre1'), type: PostMediaType.image),
          PostMedia(url: _photo('postre2'), type: PostMediaType.image),
          PostMedia(url: _photo('postre3'), type: PostMediaType.image),
        ],
        ratingAverage: 4.6,
        reviewCount: 31,
        isFeatured: true,
        likeCount: 245,
        saveCount: 88,
        shareCount: 1350,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Post(
        id: 'p4',
        author: laura,
        text:
            'Asesorías de Cálculo Diferencial e Integral en grupos pequeños '
            'en la biblioteca. La primera clase tiene descuento.',
        category: PostCategory.advisory,
        tags: const ['Matemáticas', 'Tutorías'],
        ratingAverage: 5,
        reviewCount: 8,
        likeCount: 54,
        saveCount: 21,
        shareCount: 9,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Post(
        id: 'p5',
        author: camilo,
        text: 'Clases de guitarra para principiantes 🎸. Mira un pedacito:',
        category: PostCategory.skill,
        tags: const ['Música', 'Clases'],
        media: [
          PostMedia(
            url: _photo('guitarra'),
            thumbnailUrl: _photo('guitarra'),
            type: PostMediaType.video,
          ),
        ],
        ratingAverage: 4,
        reviewCount: 5,
        likeCount: 33,
        saveCount: 5,
        shareCount: 2,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Post(
        id: 'p6',
        author: sebastian,
        text:
            'Diseño logos, flyers y presentaciones para tus trabajos o tu '
            'negocio. Entrega rápida.',
        category: PostCategory.service,
        tags: const ['Diseño', 'Arte'],
        likeCount: 6,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }
}
