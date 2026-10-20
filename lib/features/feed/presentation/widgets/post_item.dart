import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/post.dart';
import '../../domain/entities/post_list_source.dart';
import '../feed_post_actions.dart';
import 'post_card.dart';

/// Una publicación del inicio, con sus toques conectados al controlador.
/// Los botones de la derecha (me gusta, guardar…) no van aquí: flotan
/// encima de la lista y muestran la publicación que se está viendo.
class PostItem extends ConsumerWidget {
  const PostItem({super.key, required this.post, required this.source});

  final Post post;
  final PostListSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = FeedPostActions(context: context, ref: ref, source: source);

    return PostCard(
      post: post,
      onAuthorTap: () => actions.openAuthor(post),
      onOptionsTap: () => actions.openOptions(post),
      onCategoryTap: () => actions.filterByCategory(post),
      onVideoTap: () => actions.openVideo(post),
      onReviewsTap: actions.comingSoon,
      onRequestTap: actions.comingSoon,
      onChatTap: actions.comingSoon,
    );
  }
}
