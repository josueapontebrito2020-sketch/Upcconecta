import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/data_failure_message.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/feed_section.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/post_list_source.dart';
import '../controllers/feed_controller.dart';
import '../feed_post_actions.dart';
import 'post_action_rail.dart';
import 'post_item.dart';

/// Lista de publicaciones (un apartado del inicio o una pestaña de un
/// perfil). Se desliza hacia abajo como en Facebook y, jalando desde arriba,
/// se recarga.
///
/// Si se da [initialPostId], al abrir se desplaza hasta esa publicación
/// (al tocar una miniatura del perfil).
///
/// Encima, a la derecha, flota la columna de botones (como en TikTok) con
/// los datos de la publicación que se está viendo: la que cruza la línea a
/// [_focusLine] de la altura de la lista.
class FeedList extends ConsumerStatefulWidget {
  const FeedList({super.key, required this.source, this.initialPostId});

  final PostListSource source;
  final String? initialPostId;

  @override
  ConsumerState<FeedList> createState() => _FeedListState();
}

class _FeedListState extends ConsumerState<FeedList>
    with AutomaticKeepAliveClientMixin {
  /// Altura (0 arriba, 1 abajo) donde se decide cuál publicación "se ve".
  static const double _focusLine = 0.4;

  final GlobalKey _viewportKey = GlobalKey();
  final Map<String, GlobalKey> _itemKeys = {};
  List<Post> _posts = const [];
  String? _currentPostId;
  bool _scrolledToInitial = false;

  // Al cambiar de apartado y volver, la lista sigue donde estaba.
  @override
  bool get wantKeepAlive => true;

  GlobalKey _keyFor(String postId) => _itemKeys.putIfAbsent(postId, GlobalKey.new);

  /// Busca la publicación que cruza la línea de enfoque.
  void _updateCurrentPost() {
    final viewport = _viewportKey.currentContext?.findRenderObject();
    if (viewport is! RenderBox || !viewport.hasSize) return;
    final focusY = viewport.size.height * _focusLine;

    String? closestId;
    var closestDistance = double.infinity;
    for (final post in _posts) {
      final box = _itemKeys[post.id]?.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;

      final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
      final bottom = top + box.size.height;
      if (top <= focusY && bottom >= focusY) {
        closestId = post.id;
        break;
      }
      final distance = top > focusY ? top - focusY : focusY - bottom;
      if (distance < closestDistance) {
        closestDistance = distance;
        closestId = post.id;
      }
    }

    if (closestId != null && closestId != _currentPostId) {
      setState(() => _currentPostId = closestId);
    }
  }

  void _scrollToInitialPost() {
    final postId = widget.initialPostId;
    if (_scrolledToInitial || postId == null) return;
    final itemContext = _itemKeys[postId]?.currentContext;
    if (itemContext == null) return;
    _scrolledToInitial = true;
    Scrollable.ensureVisible(itemContext);
  }

  Future<void> _refresh() async {
    final l10n = context.l10n;
    final failure = await ref
        .read(feedControllerProvider(widget.source).notifier)
        .refresh();
    if (failure != null && mounted) context.showSnackBar(failure.message(l10n));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;
    final state = ref.watch(feedControllerProvider(widget.source));
    final posts = state.value;

    if (posts == null) {
      if (state.hasError) {
        final error = state.error;
        return _Message(
          icon: Icons.wifi_off_rounded,
          text: error is DataFailure ? error.message(l10n) : l10n.feedError,
          action: OutlinedButton(
            onPressed: () =>
                ref.invalidate(feedControllerProvider(widget.source)),
            child: Text(l10n.retryButton),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    _posts = posts;
    // Tras pintar (lista nueva, publicación oculta…) se revisa cuál se ve.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToInitialPost();
      _updateCurrentPost();
    });

    Post? current;
    for (final post in posts) {
      if (post.id == _currentPostId) current = post;
    }
    current ??= posts.isEmpty ? null : posts.first;

    final actions = FeedPostActions(
      context: context,
      ref: ref,
      source: widget.source,
    );

    return Column(
      children: [
        // Recargando por un filtro nuevo: barra fina arriba.
        if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: Stack(
            key: _viewportKey,
            children: [
              Positioned.fill(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: posts.isEmpty
                      ? _ScrollableMessage(
                          icon: Icons.inbox_outlined,
                          text:
                              widget.source ==
                                  const HomeFeedSource(FeedSection.featured)
                              ? l10n.feedEmptyFeatured
                              : l10n.feedEmpty,
                        )
                      : NotificationListener<ScrollUpdateNotification>(
                          onNotification: (_) {
                            _updateCurrentPost();
                            return false;
                          },
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            // Para ir a una publicación, todas deben estar
                            // construidas (las del perfil son pocas).
                            cacheExtent: widget.initialPostId == null
                                ? null
                                : 1e6,
                            padding: const EdgeInsets.fromLTRB(10, 12, 10, 28),
                            itemCount: posts.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              return KeyedSubtree(
                                key: _keyFor(post.id),
                                child: PostItem(
                                  post: post,
                                  source: widget.source,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
              if (current != null)
                Align(
                  alignment: const Alignment(1, 0.35),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _FloatingRail(post: current, actions: actions),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// La columna de botones, con una transición suave al pasar a otra
/// publicación.
class _FloatingRail extends StatelessWidget {
  const _FloatingRail({required this.post, required this.actions});

  final Post post;
  final FeedPostActions actions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.verdeProfundo.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(
              Tween<Offset>(begin: const Offset(0.4, 0), end: Offset.zero),
            ),
            child: child,
          ),
        ),
        child: PostActionRail(
          key: ValueKey(post.id),
          post: post,
          onAuthorTap: () => actions.openAuthor(post),
          onFollowTap: () => actions.follow(post),
          onLikeTap: () => actions.like(post),
          onSaveTap: () => actions.save(post),
          onShareTap: () => actions.share(post),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final extra = action;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.tintaSuave),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (extra != null) ...[const SizedBox(height: 20), extra],
          ],
        ),
      ),
    );
  }
}

/// Mensaje centrado que igual se puede jalar para recargar.
class _ScrollableMessage extends StatelessWidget {
  const _ScrollableMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: _Message(icon: icon, text: text),
        ),
      ),
    );
  }
}
