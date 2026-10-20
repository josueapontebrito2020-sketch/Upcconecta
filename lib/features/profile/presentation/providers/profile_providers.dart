import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../auth/di/auth_providers.dart';
import '../../di/profile_providers.dart';
import '../../domain/entities/follow_list_type.dart';
import '../../domain/entities/user_summary.dart';

/// Id del usuario con sesión (null si no hay sesión). Cambia al iniciar
/// sesión con otra cuenta.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.id;
});

/// Seguidores o seguidos de una persona.
final followListProvider = FutureProvider.autoDispose
    .family<List<UserSummary>, (String, FollowListType)>((ref, args) async {
      final (userId, type) = args;
      final result = await ref.read(getFollowListProvider).call(userId, type);
      return switch (result) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
    });

/// Resultado de buscar personas con el texto dado.
final userSearchProvider = FutureProvider.autoDispose
    .family<List<UserSummary>, String>((ref, query) async {
      final result = await ref.read(searchUsersUseCaseProvider).call(query);
      return switch (result) {
        Ok(:final value) => value,
        Err(:final error) => throw error,
      };
    });

/// Quién visitó mi perfil en los últimos 30 días.
final profileViewersProvider = FutureProvider.autoDispose<List<UserSummary>>((
  ref,
) async {
  final result = await ref.read(getProfileViewersProvider).call();
  return switch (result) {
    Ok(:final value) => value,
    Err(:final error) => throw error,
  };
});
