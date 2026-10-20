import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/post_category.dart';
import '../post_category_label.dart';

/// Hoja inferior para filtrar el inicio por categoría.
///
/// Devuelve la categoría elegida, [CategoryChoice.all] para quitar el filtro
/// o null si se cerró sin elegir.
Future<CategoryChoice?> showCategoryFilterSheet(
  BuildContext context, {
  required PostCategory? current,
}) {
  return showModalBottomSheet<CategoryChoice>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.superficie,
    builder: (context) => _CategoryFilterSheet(current: current),
  );
}

/// Opción elegida en el filtro: una categoría o "todas" (null).
class CategoryChoice {
  const CategoryChoice(this.category);

  static const CategoryChoice all = CategoryChoice(null);

  final PostCategory? category;
}

class _CategoryFilterSheet extends StatelessWidget {
  const _CategoryFilterSheet({required this.current});

  final PostCategory? current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    Widget chip({
      required String label,
      required IconData icon,
      required bool selected,
      required CategoryChoice choice,
    }) {
      return ChoiceChip(
        label: Text(label),
        avatar: Icon(
          icon,
          size: 18,
          color: selected ? Colors.white : AppColors.verdeUpc,
        ),
        showCheckmark: false,
        selected: selected,
        selectedColor: AppColors.verdeUpc,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.tinta,
        ),
        side: BorderSide(
          color: selected ? AppColors.verdeUpc : AppColors.borde,
        ),
        onSelected: (_) => Navigator.of(context).pop(choice),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.feedFilterTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                chip(
                  label: l10n.feedFilterAll,
                  icon: Icons.apps_rounded,
                  selected: current == null,
                  choice: CategoryChoice.all,
                ),
                for (final category in PostCategory.values)
                  chip(
                    label: category.label(l10n),
                    icon: category.icon,
                    selected: current == category,
                    choice: CategoryChoice(category),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
