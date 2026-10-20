import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/post_list_source.dart';
import '../widgets/feed_list.dart';

/// Publicaciones de una pestaña del perfil en formato de inicio (tarjetas
/// con la columna de botones). Se abre al tocar una miniatura y empieza en
/// esa publicación.
class PostListPage extends StatelessWidget {
  const PostListPage({super.key, required this.source, this.initialPostId});

  final ProfilePostsSource source;
  final String? initialPostId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (source.collection) {
      PostCollection.authored => l10n.profileTabPosts,
      PostCollection.saved => l10n.profileTabSaved,
      PostCollection.liked => l10n.profileTabLiked,
      PostCollection.shared => l10n.profileTabShared,
    };

    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.superficie,
        surfaceTintColor: Colors.transparent,
      ),
      body: Material(
        color: AppColors.fondo,
        child: FeedList(source: source, initialPostId: initialPostId),
      ),
    );
  }
}
