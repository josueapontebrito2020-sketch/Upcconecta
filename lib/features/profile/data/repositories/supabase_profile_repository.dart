import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/follow_list_type.dart';
import '../../domain/entities/profile_changes.dart';
import '../../domain/entities/profile_photo.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_summary.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_rows.dart';

/// Perfil en Supabase (migraciones 1, 2 y 4): vista `profile_details`,
/// tabla `profiles`, funciones de búsqueda y listas, y fotos en el bucket
/// `avatars`.
class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  static const String _avatarsBucket = 'avatars';

  /// Código de Postgres para "ya existe" (nombre de usuario ocupado).
  static const String _uniqueViolation = '23505';

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<Result<UserProfile, DataFailure>> getProfile(String userId) {
    return _guard('cargar el perfil', () async {
      final row = await _client
          .from('profile_details')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (row == null) throw DataFailure.notFound;

      Map<String, dynamic>? private;
      if (row['is_mine'] == true) {
        final rows = await _client.rpc<List<dynamic>>('get_my_private_profile');
        if (rows.isNotEmpty) private = rows.first as Map<String, dynamic>;
      }
      return profileFromRow(row, private: private);
    });
  }

  @override
  Future<Result<void, DataFailure>> updateProfile(ProfileChanges changes) {
    return _guard('guardar el perfil', () async {
      final userId = _userId;
      if (userId == null) throw DataFailure.unknown;

      await _client
          .from('profiles')
          .update({
            if (changes.fullName != null) 'full_name': changes.fullName,
            if (changes.username != null) 'username': changes.username,
            if (changes.bio != null) 'bio': changes.bio,
            if (changes.phone != null || changes.clearPhone)
              'phone': changes.phone,
            if (changes.facultyId != null) 'faculty_id': changes.facultyId,
            if (changes.programId != null) 'program_id': changes.programId,
            if (changes.birthDate case final birthDate?)
              'birth_date': formatIsoDate(birthDate),
          })
          .eq('id', userId);
    });
  }

  @override
  Future<Result<String, DataFailure>> uploadAvatar({
    required String userId,
    required ProfilePhoto photo,
  }) {
    return _guard('subir la foto de perfil', () async {
      // Cada usuario tiene su carpeta: avatars/<id>/avatar.jpg
      final path = '$userId/avatar.${photo.extension}';
      final bucket = _client.storage.from(_avatarsBucket);

      await bucket.uploadBinary(
        path,
        photo.bytes,
        fileOptions: FileOptions(contentType: photo.contentType, upsert: true),
      );

      // El parámetro ?v= evita que el teléfono muestre la foto anterior
      // guardada en caché.
      final version = DateTime.now().millisecondsSinceEpoch;
      final url = '${bucket.getPublicUrl(path)}?v=$version';

      await _client
          .from('profiles')
          .update({'avatar_url': url})
          .eq('id', userId);
      return url;
    });
  }

  @override
  Future<Result<bool, DataFailure>> isUsernameAvailable(String username) {
    return _guard('revisar el nombre de usuario', () async {
      final available = await _client.rpc<dynamic>(
        'is_username_available',
        params: {'p_username': username},
      );
      return available == true;
    });
  }

  @override
  Future<Result<List<UserSummary>, DataFailure>> searchUsers(String query) {
    return _users('search_users', {'p_query': query});
  }

  @override
  Future<Result<List<UserSummary>, DataFailure>> getFollowList(
    String userId,
    FollowListType type,
  ) {
    return _users(switch (type) {
      FollowListType.followers => 'get_followers',
      FollowListType.following => 'get_following',
    }, {'p_user_id': userId});
  }

  @override
  Future<Result<void, DataFailure>> registerProfileView(String profileId) {
    return _guard('registrar la visita', () async {
      await _client.rpc<dynamic>(
        'register_profile_view',
        params: {'p_profile_id': profileId},
      );
    });
  }

  @override
  Future<Result<List<UserSummary>, DataFailure>> getProfileViewers() {
    return _users('get_profile_viewers', null);
  }

  /// Llama a una función que devuelve personas.
  Future<Result<List<UserSummary>, DataFailure>> _users(
    String function,
    Map<String, dynamic>? params,
  ) {
    return _guard(function, () async {
      final rows = await _client.rpc<List<dynamic>>(function, params: params);
      return [
        for (final row in rows) userSummaryFromRow(row as Map<String, dynamic>),
      ];
    });
  }

  /// Ejecuta una operación y convierte cualquier error en [DataFailure].
  Future<Result<T, DataFailure>> _guard<T>(
    String action,
    Future<T> Function() operation,
  ) async {
    try {
      return Ok(await operation());
    } on DataFailure catch (failure) {
      return Err(failure);
    } on PostgrestException catch (error) {
      developer.log('Error al $action', error: error);
      return Err(
        error.code == _uniqueViolation
            ? DataFailure.conflict
            : DataFailure.unknown,
      );
    } on StorageException catch (error) {
      developer.log('Error al $action', error: error);
      return const Err(DataFailure.unknown);
    } catch (error) {
      developer.log('Error al $action', error: error);
      return const Err(DataFailure.network);
    }
  }
}
