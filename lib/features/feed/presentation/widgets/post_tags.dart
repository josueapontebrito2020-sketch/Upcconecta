import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/post.dart';
import '../post_category_label.dart';

/// Categoría (verde, se puede tocar para filtrar) y etiquetas de la
/// publicación.
class PostTags extends StatelessWidget {
  const PostTags({super.key, required this.post, required this.onCategoryTap});

  final Post post;
  final VoidCallback onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final category = post.category;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        Material(
          color: AppColors.verdeUpc.withValues(alpha: 0.10),
          shape: const StadiumBorder(),
          child: InkWell(
            onTap: onCategoryTap,
            customBorder: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category.icon, size: 15, color: AppColors.verdeUpc),
                  const SizedBox(width: 4),
                  Text(
                    category.label(context.l10n),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.verdeUpc,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        for (final tag in post.tags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: ShapeDecoration(
              shape: const StadiumBorder(
                side: BorderSide(color: AppColors.borde),
              ),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.tintaSuave,
              ),
            ),
          ),
      ],
    );
  }
}
