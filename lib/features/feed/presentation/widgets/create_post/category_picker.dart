import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/post_category.dart';
import '../../post_category_label.dart';

/// Las cuatro categorías como chips; se elige una.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PostCategory? selected;
  final ValueChanged<PostCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in PostCategory.values)
          ChoiceChip(
            label: Text(category.label(l10n)),
            avatar: Icon(
              category.icon,
              size: 18,
              color: category == selected ? Colors.white : AppColors.verdeUpc,
            ),
            showCheckmark: false,
            selected: category == selected,
            selectedColor: AppColors.verdeUpc,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: category == selected ? Colors.white : AppColors.tinta,
            ),
            side: BorderSide(
              color: category == selected ? AppColors.verdeUpc : AppColors.borde,
            ),
            onSelected: (_) => onSelected(category),
          ),
      ],
    );
  }
}
