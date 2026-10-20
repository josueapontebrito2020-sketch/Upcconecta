import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../../di/feed_providers.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/post_list_source.dart';
import '../../domain/entities/post_category.dart';
import '../../domain/entities/report_reason.dart';
import 'feed_category_filter_provider.dart';

/// Una lista de publicaciones: un apartado del inicio (Destacados o
/// Comunidad, que se recargan solos al cambiar el filtro) o una pestaña de
/// un perfil.
///
/// Los botones (me gusta, guardar, seguir) cambian la pantalla al instante
/// y, si el servidor falla, se deshace el cambio y se devuelve el fallo para
/// mostrar un aviso.
final feedControllerProvider = AsyncNotifierProvider.autoDispose
    .family<FeedController, List<Post>, PostListSource>(FeedController.new);

/// Listas abiertas en este momento. Una misma publicación puede estar en
/// varias (Comunidad, Destacados, mi perfil…): los cambios se aplican en
/// todas.
final _openListsProvider = Provider<Set<FeedController>>((ref) => {});

class FeedController extends AsyncNotifier<List<Post>> {
  FeedController(this.source);

  final PostListSource source;

  @override
  Future<List<Post>> build() {
    final openLists = ref.read(_openListsProvider)..add(this);
    ref.onDispose(() => openLists.remove(this));

    return switch (source) {
      HomeFeedSource() => _fetch(ref.watch(feedCategoryFilterProvider)),
      ProfilePostsSource() => _fetch(null),
    };
  }

  Future<List<Post>> _fetch(PostCategory? category) async {
    final result = switch (source) {
      HomeFeedSource(:final section) => await ref
          .read(getFeedPostsProvider)
          .call(section: section, category: category),
      ProfilePostsSource(:final userId, :final collection) => await ref
          .read(getProfilePostsProvider)
          .call(userId: userId, collection: collection),
    };
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };
  }

  /// Deslizar hacia abajo para recargar. Si falla y ya había publicaciones,
  /// se conservan y se devuelve el fallo.
  Future<DataFailure?> refresh() async {
    final category = source is HomeFeedSource
        ? ref.read(feedCategoryFilterProvider)
        : null;
    final next = await AsyncValue.guard(() => _fetch(category));
    if (!ref.mounted) return null;

    if (next.hasError && state.hasValue) {
      final error = next.error;
      return error is DataFailure ? error : DataFailure.unknown;
    }
    state = next;
    return null;
  }

  Future<DataFailure?> toggleLike(Post post) async {
    final liked = !post.isLiked;
    Post apply(Post p, bool value) {
      if (p.isLiked == value) return p;
      return p.copyWith(
        isLiked: value,
        likeCount: p.likeCount + (value ? 1 : -1),
      );
    }

    _updateEverywhere((p) => p.id == post.id, (p) => apply(p, liked));
    final result = await ref
        .read(toggleLikeProvider)
        .call(post.id, liked: liked);
    return _undoIfFailed(
      result,
      () => _updateEverywhere((p) => p.id == post.id, (p) => apply(p, !liked)),
    );
  }

  Future<DataFailure?> toggleSave(Post post) async {
    final saved = !post.isSaved;
    Post apply(Post p, bool value) {
      if (p.isSaved == value) return p;
      return p.copyWith(
        isSaved: value,
        saveCount: p.saveCount + (value ? 1 : -1),
      );
    }

    _updateEverywhere((p) => p.id == post.id, (p) => apply(p, saved));
    final result = await ref
        .read(toggleSaveProvider)
        .call(post.id, saved: saved);
    return _undoIfFailed(
      result,
      () => _updateEverywhere((p) => p.id == post.id, (p) => apply(p, !saved)),
    );
  }

  /// Suma uno a los compartidos (el texto ya se copió en la pantalla).
  Future<DataFailure?> registerShare(Post post) async {
    Post add(Post p, int delta) => p.copyWith(shareCount: p.shareCount + delta);

    _updateEverywhere((p) => p.id == post.id, (p) => add(p, 1));
    final result = await ref.read(registerShareProvider).call(post.id);
    return _undoIfFailed(
      result,
      () => _updateEverywhere((p) => p.id == post.id, (p) => add(p, -1)),
    );
  }

  /// Seguir afecta a todas las publicaciones del mismo autor.
  Future<DataFailure?> toggleFollow(Post post) async {
    final authorId = post.author.id;
    final following = !post.isFollowingAuthor;
    _updateEverywhere(
      (p) => p.author.id == authorId,
      (p) => p.copyWith(isFollowingAuthor: following),
    );
    final result = await ref
        .read(toggleFollowProvider)
        .call(authorId, following: following);
    return _undoIfFailed(
      result,
      () => _updateEverywhere(
        (p) => p.author.id == authorId,
        (p) => p.copyWith(isFollowingAuthor: !following),
      ),
    );
  }

  /// Oculta la publicación. Si falla, vuelve a cargar la lista.
  Future<DataFailure?> hide(Post post) async {
    _removeEverywhere(post.id);
    final result = await ref.read(hidePostProvider).call(post.id);
    return _undoIfFailed(result, () => ref.invalidateSelf());
  }

  /// Borra una publicación propia. Si falla, vuelve a cargar la lista.
  Future<DataFailure?> delete(Post post) async {
    _removeEverywhere(post.id);
    final result = await ref.read(deletePostProvider).call(post.id);
    return _undoIfFailed(result, () => ref.invalidateSelf());
  }

  Future<DataFailure?> report(Post post, ReportReason reason) async {
    final result = await ref.read(reportPostProvider).call(post.id, reason);
    return switch (result) {
      Ok() => null,
      Err(:final error) => error,
    };
  }

  DataFailure? _undoIfFailed(
    Result<void, DataFailure> result,
    void Function() undo,
  ) {
    switch (result) {
      case Ok():
        return null;
      case Err(:final error):
        if (ref.mounted) undo();
        return error;
    }
  }

  /// La misma publicación puede estar en varias listas abiertas: el cambio
  /// se aplica en todas.
  void _updateEverywhere(
    bool Function(Post post) where,
    Post Function(Post post) update,
  ) {
    for (final controller in _openControllers()) {
      controller._replaceWhere(where, update);
    }
  }

  void _removeEverywhere(String postId) {
    for (final controller in _openControllers()) {
      controller._removeWhere((p) => p.id == postId);
    }
  }

  Iterable<FeedController> _openControllers() {
    if (!ref.mounted) return const [];
    // Copia: la lista puede cambiar mientras se recorre.
    return [...ref.read(_openListsProvider)];
  }

  void _removeWhere(bool Function(Post post) where) {
    final posts = state.value;
    if (posts == null) return;
    state = AsyncData([
      for (final p in posts)
        if (!where(p)) p,
    ]);
  }

  void _replaceWhere(
    bool Function(Post post) where,
    Post Function(Post post) update,
  ) {
    final posts = state.value;
    if (posts == null) return;
    state = AsyncData([
      for (final p in posts) where(p) ? update(p) : p,
    ]);
  }
}
