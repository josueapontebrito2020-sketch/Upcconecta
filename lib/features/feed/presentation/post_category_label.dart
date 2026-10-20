import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/entities/post_category.dart';

/// Nombre e ícono de cada categoría, para chips y filtros.
extension PostCategoryLabel on PostCategory {
  String label(AppLocalizations l10n) {
    return switch (this) {
      PostCategory.product => l10n.categoryProduct,
      PostCategory.service => l10n.categoryService,
      PostCategory.skill => l10n.categorySkill,
      PostCategory.advisory => l10n.categoryAdvisory,
    };
  }

  IconData get icon {
    return switch (this) {
      PostCategory.product => Icons.shopping_bag_outlined,
      PostCategory.service => Icons.handyman_outlined,
      PostCategory.skill => Icons.emoji_objects_outlined,
      PostCategory.advisory => Icons.school_outlined,
    };
  }
}
