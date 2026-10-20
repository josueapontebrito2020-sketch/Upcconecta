import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../feed/presentation/controllers/feed_controller.dart';
import '../../di/profile_providers.dart';
import '../../domain/entities/profile_changes.dart';
import '../../domain/entities/profile_photo.dart';
import '../providers/profile_providers.dart';
import 'profile_controller.dart';

/// Guarda los cambios de "Editar perfil": en reposo, guardando
/// (`AsyncLoading`) o con error (`AsyncError` con un `DataFailure`).
final editProfileControllerProvider =
    AsyncNotifierProvider.autoDispose<EditProfileController, void>(
      EditProfileController.new,
    );

class EditProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Guarda y devuelve true si salió bien.
  Future<bool> save(ProfileChanges changes) async {
    state = const AsyncLoading<void>();
    final result = await ref.read(updateProfileProvider).call(changes);
    return _finish(result);
  }

  Future<bool> changePhoto(ProfilePhoto photo) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return false;
    state = const AsyncLoading<void>();
    final result = await ref
        .read(uploadAvatarProvider)
        .call(userId: userId, photo: photo);
    return _finish(result);
  }

  bool _finish(Result<Object?, Object> result) {
    if (!ref.mounted) return result is Ok;
    switch (result) {
      case Ok():
        state = const AsyncData<void>(null);
        // El perfil y las publicaciones muestran el nombre y la foto nuevos.
        final userId = ref.read(currentUserIdProvider);
        if (userId != null) ref.invalidate(profileControllerProvider(userId));
        ref.invalidate(feedControllerProvider);
        return true;
      case Err(:final error):
        state = AsyncError<void>(error, StackTrace.current);
        return false;
    }
  }
}
