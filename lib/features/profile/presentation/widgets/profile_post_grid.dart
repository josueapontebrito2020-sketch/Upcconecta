import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/data_failure_message.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../feed/domain/entities/post.dart';
import '../../../feed/domain/entities/post_list_source.dart';
import '../../../feed/presentation/controllers/feed_controller.dart';

/// Cuadrícula de 3 columnas con las publicaciones de una pestaña del perfil.
/// Cada miniatura muestra los me gusta; al tocarla se abren las
/// publicaciones completas desde esa.
///
/// Va dentro del `NestedScrollView` del perfil: por eso usa
/// `SliverOverlapInjector` (para no quedar debajo de las pestañas).
class ProfilePostGrid extends ConsumerWidget {
  const ProfilePostGrid({
    super.key,
    required this.source,
    required this.emptyIcon,
    required this.emptyText,
  });

  final ProfilePostsSource source;
  final IconData emptyIcon;
  final String emptyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(feedControllerProvider(source));
    final posts = state.value;

    final Widget content;
    if (posts == null) {
      final error = state.error;
      content = SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: state.hasError
              ? _Message(
                  icon: Icons.wifi_off_rounded,
                  text: error is DataFailure
                      ? error.message(l10n)
                      : l10n.feedError,
                  action: TextButton(
                    onPressed: () =>
                        ref.invalidate(feedControllerProvider(source)),
                    child: Text(l10n.retryButton),
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
        ),
      );
    } else if (posts.isEmpty) {
      content = SliverFillRemaining(
        hasScrollBody: false,
        child: _Message(icon: emptyIcon, text: emptyText),
      );
    } else {
      content = SliverPadding(
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 24),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 3 / 4,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) => _PostTile(
            post: posts[index],
            onTap: () => context.push(
              Uri(
                path: AppRoutes.postList,
                queryParameters: {
                  'usuario': source.userId,
                  'tipo': source.collection.name,
                  'inicio': posts[index].id,
                },
              ).toString(),
            ),
          ),
        ),
      );
    }

    return Builder(
      builder: (context) => CustomScrollView(
        key: PageStorageKey(source.collection.name),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          content,
        ],
      ),
    );
  }
}

/// Miniatura: la primera foto, un fondo oscuro con ▶ si es video, o el
/// texto sobre verde si no tiene archivos. Abajo, los me gusta.
class _PostTile extends StatelessWidget {
  const _PostTile({required this.post, required this.onTap});

  final Post post;
  final VoidCallback onTap;

  static final NumberFormat _compact = NumberFormat.compact(locale: 'es');

  @override
  Widget build(BuildContext context) {
    final media = post.media.isEmpty ? null : post.media.first;

    final Widget background;
    if (media == null) {
      background = DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.verdeHoja, AppColors.verdeProfundo],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 28),
          child: Text(
            post.text,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      );
    } else if (media.isVideo && media.thumbnailUrl == null) {
      background = const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.verdeProfundo, AppColors.tinta],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.play_circle_outline_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
      );
    } else {
      background = Image.network(
        media.thumbnailUrl ?? media.url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const ColoredBox(color: AppColors.campo),
      );
    }

    return Semantics(
      button: true,
      label: post.text,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            background,
            // Sombra abajo para que el contador se lea sobre cualquier foto.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x99000000)],
                ),
              ),
            ),
            if (media != null && media.isVideo)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.videocam, size: 18, color: Colors.white),
              )
            else if (post.media.length > 1)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.collections, size: 18, color: Colors.white),
              ),
            if (post.isFeatured)
              const Positioned(
                top: 6,
                left: 6,
                child: Icon(Icons.bolt, size: 18, color: AppColors.amarillo),
              ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite_border_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _compact.format(post.likeCount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: AppColors.tintaSuave),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (extra != null) extra,
        ],
      ),
    );
  }
}
