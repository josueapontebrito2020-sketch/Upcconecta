import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../domain/entities/post.dart';

/// Columna de botones que flota a la derecha, encima de las publicaciones,
/// como en TikTok o Reels: perfil del autor (con "+" para seguir), me gusta,
/// guardar y compartir, cada uno con su contador.
///
/// Muestra siempre la publicación que se está viendo; al deslizar a otra,
/// los datos cambian.
class PostActionRail extends StatelessWidget {
  const PostActionRail({
      super.key,
      required this.post,
      required this.onAuthorTap,
      required this.onFollowTap,
      required this.onLikeTap,
      required this.onSaveTap,
      required this.onShareTap,
  });

  final Post post;
  final VoidCallback onAuthorTap;
  final VoidCallback onFollowTap;
  final VoidCallback onLikeTap;
  final VoidCallback onSaveTap;
  final VoidCallback onShareTap;

  static final NumberFormat _compact = NumberFormat.compact(locale: 'es');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Fondo blanco translúcido y desenfocado: deja ver la publicación de
    // atrás sin perder los íconos.
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
          ),
          // Material transparente: aquí se ven las ondas al tocar.
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AuthorButton(
                    post: post,
                    onAuthorTap: onAuthorTap,
                    onFollowTap: onFollowTap,
                  ),
                  const SizedBox(height: 6),
                  _RailButton(
                    tooltip: l10n.railLike,
                    selected: post.isLiked,
                    icon: Icons.favorite_border_rounded,
                    selectedIcon: Icons.favorite_rounded,
                    selectedColor: AppColors.corazon,
                    count: _compact.format(post.likeCount),
                    onTap: onLikeTap,
                  ),
                  _RailButton(
                    tooltip: post.isSaved ? l10n.railSaved : l10n.railSave,
                    selected: post.isSaved,
                    icon: Icons.bookmark_border_rounded,
                    selectedIcon: Icons.bookmark_rounded,
                    selectedColor: AppColors.verdeUpc,
                    count: _compact.format(post.saveCount),
                    onTap: onSaveTap,
                  ),
                  _RailButton(
                    tooltip: l10n.railShare,
                    selected: false,
                    icon: Icons.reply_rounded,
                    selectedIcon: Icons.reply_rounded,
                    selectedColor: AppColors.tinta,
                    flipIcon: true,
                    count: _compact.format(post.shareCount),
                    onTap: onShareTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Foto del autor con un círculo "+" abajo para seguirlo (✓ si ya lo sigue).
class _AuthorButton extends StatelessWidget {
  const _AuthorButton({
      required this.post,
      required this.onAuthorTap,
      required this.onFollowTap,
  });

  final Post post;
  final VoidCallback onAuthorTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final author = post.author;
    final following = post.isFollowingAuthor;

    return SizedBox(
      width: 40,
      height: 48,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Semantics(
            button: true,
            label: author.fullName,
            child: GestureDetector(
              onTap: onAuthorTap,
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: UserAvatar(
                  name: author.fullName,
                  imageUrl: author.avatarUrl,
                  size: 36,
                ),
              ),
            ),
          ),
          // En las publicaciones propias no hay botón de seguir.
          if (!post.isMine) ...[
            Positioned(
              bottom: 0,
              child: Tooltip(
                message: following
                    ? l10n.railFollowing(author.fullName)
                    : l10n.railFollow(author.fullName),
                child: Semantics(
                  button: true,
                  toggled: following,
                  child: GestureDetector(
                    onTap: onFollowTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: following ? Colors.white : AppColors.verdeUpc,
                        border: Border.all(
                          color: following ? AppColors.verdeUpc : Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        following ? Icons.check_rounded : Icons.add_rounded,
                        size: 12,
                        color: following ? AppColors.verdeUpc : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
      required this.tooltip,
      required this.selected,
      required this.icon,
      required this.selectedIcon,
      required this.selectedColor,
      required this.count,
      required this.onTap,
      this.flipIcon = false,
  });

  final String tooltip;
  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final Color selectedColor;
  final String count;
  final VoidCallback onTap;
  final bool flipIcon;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      selected ? selectedIcon : icon,
      key: ValueKey(selected),
      size: 24,
      color: selected ? selectedColor : AppColors.tinta,
    );
    if (flipIcon) iconWidget = Transform.flip(flipX: true, child: iconWidget);

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        toggled: flipIcon ? null : selected,
        label: '$tooltip, $count',
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 24,
          child: SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation.drive(
                        Tween<double>(begin: 0.6, end: 1).chain(
                          CurveTween(curve: Curves.easeOutBack),
                        ),
                      ),
                      child: child,
                    ),
                    child: iconWidget,
                  ),
                  const SizedBox(height: 1),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      count,
                      key: ValueKey(count),
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tinta,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
