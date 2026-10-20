import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/expandable_text.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../domain/entities/post.dart';
import 'post_header.dart';
import 'post_media_gallery.dart';
import 'post_tags.dart';

/// Tarjeta blanca de la publicación, al estilo Facebook: cabecera, texto,
/// fotos o video, categoría y etiquetas, calificación, reseñas y los botones
/// para solicitar y para escribirle al autor.
class PostCard extends StatelessWidget {
  const PostCard({
      super.key,
      required this.post,
      required this.onAuthorTap,
      required this.onOptionsTap,
      required this.onCategoryTap,
      required this.onVideoTap,
      required this.onReviewsTap,
      required this.onRequestTap,
      required this.onChatTap,
  });

  final Post post;
  final VoidCallback onAuthorTap;
  final VoidCallback onOptionsTap;
  final VoidCallback onCategoryTap;
  final VoidCallback onVideoTap;
  final VoidCallback onReviewsTap;
  final VoidCallback onRequestTap;
  final VoidCallback onChatTap;

  /// Sombra suave: la tarjeta "flota" sobre el fondo.
  static final List<BoxShadow> shadow = [
    BoxShadow(
      color: AppColors.verdeProfundo.withValues(alpha: 0.10),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    final radius = BorderRadius.circular(20);

    // DecoratedBox pone la sombra; Material, el fondo blanco donde se ven
    // las ondas al tocar.
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: shadow),
      child: Material(
        color: AppColors.superficie,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 4, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PostHeader(
                post: post,
                onAuthorTap: onAuthorTap,
                onOptionsTap: onOptionsTap,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    ExpandableText(
                      post.text,
                      seeMoreLabel: l10n.postSeeMore,
                      seeLessLabel: l10n.postSeeLess,
                      style: textTheme.bodyLarge?.copyWith(fontSize: 15),
                    ),
                    if (post.media.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      PostMediaGallery(
                        media: post.media,
                        onVideoTap: onVideoTap,
                      ),
                    ],
                    const SizedBox(height: 12),
                    PostTags(post: post, onCategoryTap: onCategoryTap),
                    const SizedBox(height: 10),
                    _RatingRow(post: post, onReviewsTap: onReviewsTap),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: onRequestTap,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                            ),
                            icon: const Icon(Icons.handshake_outlined, size: 20),
                            label: Text(l10n.postRequest),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.outlined(
                          onPressed: onChatTap,
                          tooltip: l10n.postChatTooltip,
                          style: IconButton.styleFrom(
                            fixedSize: const Size.square(44),
                            foregroundColor: AppColors.verdeUpc,
                            side: const BorderSide(color: AppColors.borde),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Estrellas, promedio y enlace a las reseñas de quienes contrataron.
class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.post, required this.onReviewsTap});

  final Post post;
  final VoidCallback onReviewsTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    if (!post.hasRatings) {
      return Row(
        children: [
          const StarRating(value: 0),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l10n.postNoRatings,
              style: textTheme.bodySmall?.copyWith(color: AppColors.tintaSuave),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        StarRating(value: post.ratingAverage),
        const SizedBox(width: 6),
        Text(
          post.ratingAverage.toStringAsFixed(1),
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.tinta,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onReviewsTap,
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          icon: const Icon(Icons.rate_review_outlined, size: 18),
          label: Text(l10n.postReviews(post.reviewCount)),
        ),
      ],
    );
  }
}
