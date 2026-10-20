import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../domain/entities/post.dart';

/// Cabecera de la publicación: foto, nombre, verificado, hace cuánto,
/// insignia de destacado y los tres puntos de opciones.
class PostHeader extends StatelessWidget {
  const PostHeader({
    super.key,
    required this.post,
    required this.onAuthorTap,
    required this.onOptionsTap,
  });

  final Post post;
  final VoidCallback onAuthorTap;
  final VoidCallback onOptionsTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final author = post.author;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onAuthorTap,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                UserAvatar(
                  name: author.fullName,
                  imageUrl: author.avatarUrl,
                  size: 42,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              author.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.tinta,
                              ),
                            ),
                          ),
                          if (author.isVerified) ...[
                            const SizedBox(width: 4),
                            Tooltip(
                              message: l10n.postVerified,
                              child: const Icon(
                                Icons.verified,
                                size: 16,
                                color: AppColors.verdeUpc,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '@${author.username} · '
                        '${timeAgo(post.createdAt, l10n)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.tintaSuave,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (post.isFeatured) ...[
          const SizedBox(width: 6),
          const FeaturedBadge(),
        ],
        IconButton(
          onPressed: onOptionsTap,
          tooltip: l10n.postOptionsTooltip,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.more_vert, color: AppColors.tintaSuave),
        ),
      ],
    );
  }
}

/// Insignia amarilla de publicación destacada.
class FeaturedBadge extends StatelessWidget {
  const FeaturedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.amarillo,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.amarillo.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 14, color: AppColors.tinta),
          const SizedBox(width: 2),
          Text(
            context.l10n.postFeatured,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.tinta,
            ),
          ),
        ],
      ),
    );
  }
}
