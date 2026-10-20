import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/post_category.dart';

/// Categoría elegida con el botón de filtro del inicio (null = todas).
/// Se aplica a Destacados y a Comunidad.
final feedCategoryFilterProvider =
    NotifierProvider.autoDispose<FeedCategoryFilter, PostCategory?>(
      FeedCategoryFilter.new,
    );

class FeedCategoryFilter extends Notifier<PostCategory?> {
  @override
  PostCategory? build() => null;

  void select(PostCategory? category) => state = category;
}
