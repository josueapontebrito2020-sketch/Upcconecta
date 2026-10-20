import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcconect/features/feed/data/repositories/fake_feed_repository.dart';
import 'package:upcconect/features/feed/di/feed_providers.dart';
import 'package:upcconect/features/feed/domain/entities/feed_section.dart';
import 'package:upcconect/features/feed/domain/entities/post_category.dart';
import 'package:upcconect/features/feed/domain/entities/post_list_source.dart';
import 'package:upcconect/features/feed/presentation/controllers/feed_category_filter_provider.dart';
import 'package:upcconect/features/feed/presentation/controllers/feed_controller.dart';

void main() {
  late ProviderContainer container;
  final community = feedControllerProvider(
    const HomeFeedSource(FeedSection.community),
  );
  final featured = feedControllerProvider(
    const HomeFeedSource(FeedSection.featured),
  );

  setUp(() {
    container = ProviderContainer(
      overrides: [
        feedRepositoryProvider.overrideWithValue(
          FakeFeedRepository(latency: Duration.zero),
        ),
      ],
    );
    // Mantiene vivos los proveedores autoDispose durante la prueba.
    container.listen(community, (_, _) {});
    container.listen(featured, (_, _) {});
    container.listen(feedCategoryFilterProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  test('Destacados solo trae publicaciones destacadas', () async {
    final posts = await container.read(featured.future);

    expect(posts, isNotEmpty);
    expect(posts.every((post) => post.isFeatured), isTrue);
  });

  test('el filtro deja solo la categoría elegida', () async {
    container
        .read(feedCategoryFilterProvider.notifier)
        .select(PostCategory.service);
    final posts = await container.read(community.future);

    expect(posts, isNotEmpty);
    expect(posts.every((post) => post.category == PostCategory.service), isTrue);
  });

  test('me gusta suma uno y se ve también en Destacados', () async {
    final posts = await container.read(community.future);
    await container.read(featured.future);
    final post = posts.firstWhere((p) => p.isFeatured);

    final failure = await container
        .read(community.notifier)
        .toggleLike(post);

    expect(failure, isNull);
    final updated = container
        .read(community)
        .requireValue
        .firstWhere((p) => p.id == post.id);
    expect(updated.isLiked, isTrue);
    expect(updated.likeCount, post.likeCount + 1);

    final inFeatured = container
        .read(featured)
        .requireValue
        .firstWhere((p) => p.id == post.id);
    expect(inFeatured.isLiked, isTrue);
  });

  test('guardar y compartir actualizan sus contadores', () async {
    final posts = await container.read(community.future);
    final post = posts.first;
    final controller = container.read(community.notifier);

    await controller.toggleSave(post);
    await controller.registerShare(post);

    final updated = container
        .read(community)
        .requireValue
        .firstWhere((p) => p.id == post.id);
    expect(updated.isSaved, isTrue);
    expect(updated.saveCount, post.saveCount + 1);
    expect(updated.shareCount, post.shareCount + 1);
  });

  test('ocultar quita la publicación de la lista', () async {
    final posts = await container.read(community.future);
    final post = posts.first;

    await container.read(community.notifier).hide(post);

    final remaining = container.read(community).requireValue;
    expect(remaining.any((p) => p.id == post.id), isFalse);
  });
}
