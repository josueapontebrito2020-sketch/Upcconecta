import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../di/feed_providers.dart';
import '../../domain/entities/new_post.dart';
import 'feed_controller.dart';

/// Estado de la pantalla "Publicar": en reposo, subiendo (`AsyncLoading`)
/// o con error (`AsyncError` con un `DataFailure`).
final createPostControllerProvider =
    AsyncNotifierProvider.autoDispose<CreatePostController, void>(
      CreatePostController.new,
    );

class CreatePostController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Publica y, si sale bien, recarga el inicio. Devuelve true si se publicó.
  Future<bool> submit(NewPost post) async {
    state = const AsyncLoading<void>();
    final result = await ref.read(createPostProvider).call(post);
    if (!ref.mounted) return result is Ok;

    switch (result) {
      case Ok():
        // Destacados y Comunidad vuelven a cargar con la publicación nueva.
        ref.invalidate(feedControllerProvider);
        state = const AsyncData<void>(null);
        return true;
      case Err(:final error):
        state = AsyncError<void>(error, StackTrace.current);
        return false;
    }
  }
}
