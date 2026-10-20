import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/data_failure.dart';
import '../../../core/errors/data_failure_message.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/app_routes.dart';
import '../domain/entities/post.dart';
import '../domain/entities/post_list_source.dart';
import 'controllers/feed_category_filter_provider.dart';
import 'controllers/feed_controller.dart';
import 'widgets/post_options_sheet.dart';

/// Lo que pasa al tocar algo en una publicación (tarjeta o botones de la
/// derecha): llama al controlador y muestra los avisos.
///
/// Tarjeta y columna de botones usan esta misma clase, así la lógica está en
/// un solo lugar.
class FeedPostActions {
  const FeedPostActions({
    required this.context,
    required this.ref,
    required this.source,
  });

  final BuildContext context;
  final WidgetRef ref;
  final PostListSource source;

  FeedController get _controller =>
      ref.read(feedControllerProvider(source).notifier);

  /// Ejecuta una acción y, si falla, muestra el aviso.
  Future<void> _run(Future<DataFailure?> Function() action) async {
    final l10n = context.l10n;
    final failure = await action();
    if (failure != null && context.mounted) {
      context.showSnackBar(failure.message(l10n));
    }
  }

  /// Lo que todavía no existe (perfiles, chat, solicitudes, reseñas, video).
  void comingSoon() => context.showSnackBar(context.l10n.comingSoon);

  Future<void> like(Post post) => _run(() => _controller.toggleLike(post));

  Future<void> save(Post post) => _run(() => _controller.toggleSave(post));

  Future<void> follow(Post post) => _run(() => _controller.toggleFollow(post));

  /// Copia el texto para pegarlo en otra app y suma un compartido.
  Future<void> share(Post post) async {
    final l10n = context.l10n;
    await Clipboard.setData(
      ClipboardData(text: l10n.shareText(post.text, post.author.fullName)),
    );
    if (!context.mounted) return;
    context.showSnackBar(l10n.shareCopied);
    await _run(() => _controller.registerShare(post));
  }

  /// Abre el perfil del autor (si soy yo, mi pestaña Perfil).
  void openAuthor(Post post) {
    if (post.isMine) {
      context.go(AppRoutes.profile);
    } else {
      context.push(AppRoutes.userProfilePath(post.author.id));
    }
  }

  /// Abre el video en pantalla completa.
  void openVideo(Post post) {
    final video = post.media.where((media) => media.isVideo).firstOrNull;
    if (video == null || video.url.isEmpty) {
      comingSoon();
      return;
    }
    context.push(
      Uri(
        path: AppRoutes.videoViewer,
        queryParameters: {'url': video.url},
      ).toString(),
    );
  }

  /// Tocar la categoría filtra el inicio por ella.
  void filterByCategory(Post post) {
    ref.read(feedCategoryFilterProvider.notifier).select(post.category);
  }

  /// Tres puntos: ocultar o reportar.
  Future<void> openOptions(Post post) async {
    final l10n = context.l10n;
    final option = await showPostOptionsSheet(context, isMine: post.isMine);
    if (option == null || !context.mounted) return;

    switch (option) {
      case PostOption.hide:
        final hideFailure = await _controller.hide(post);
        if (!context.mounted) return;
        context.showSnackBar(
          hideFailure == null ? l10n.postHidden : hideFailure.message(l10n),
        );
      case PostOption.delete:
        if (!await confirmDeletePost(context) || !context.mounted) return;
        final deleteFailure = await _controller.delete(post);
        if (!context.mounted) return;
        context.showSnackBar(
          deleteFailure == null
              ? l10n.postDeleted
              : deleteFailure.message(l10n),
        );
      case PostOption.report:
        final reason = await showReportReasonDialog(context);
        if (reason == null || !context.mounted) return;
        final reportFailure = await _controller.report(post, reason);
        if (!context.mounted) return;
        context.showSnackBar(
          reportFailure == null
              ? l10n.postReported
              : reportFailure.message(l10n),
        );
    }
  }
}
