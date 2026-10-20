import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../../../feed/di/feed_providers.dart';
import '../../../feed/presentation/controllers/feed_controller.dart';
import '../../di/profile_providers.dart';
import '../../domain/entities/user_profile.dart';

/// Perfil de una persona (el mío o el de otra). Al abrir el de otra
/// persona, cuenta la visita.
final profileControllerProvider = AsyncNotifierProvider.autoDispose
    .family<ProfileController, UserProfile, String>(ProfileController.new);

class ProfileController extends AsyncNotifier<UserProfile> {
  ProfileController(this.userId);

  final String userId;
  bool _viewRegistered = false;

  @override
  Future<UserProfile> build() async {
    final result = await ref.read(getProfileProvider).call(userId);
    final profile = switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };

    if (!profile.isMine && !_viewRegistered) {
      _viewRegistered = true;
      unawaited(ref.read(registerProfileViewProvider).call(userId));
    }
    return profile;
  }

  /// Vuelve a cargar sin borrar lo que se ve mientras tanto.
  Future<void> refresh() async {
    final result = await ref.read(getProfileProvider).call(userId);
    if (!ref.mounted) return;
    if (result case Ok(:final value)) state = AsyncData(value);
  }

  /// Seguir o dejar de seguir. Cambia al instante y, si falla, se deshace.
  Future<DataFailure?> toggleFollow() async {
    final profile = state.value;
    if (profile == null || profile.isMine) return null;

    final following = !profile.isFollowing;
    state = AsyncData(
      profile.copyWith(
        isFollowing: following,
        followersCount: profile.followersCount + (following ? 1 : -1),
      ),
    );

    final result = await ref
        .read(toggleFollowProvider)
        .call(userId, following: following);
    if (!ref.mounted) return null;

    switch (result) {
      case Ok():
        // El botón "+" de las publicaciones de esta persona cambia también.
        ref.invalidate(feedControllerProvider);
        return null;
      case Err(:final error):
        state = AsyncData(profile);
        return error;
    }
  }
}
