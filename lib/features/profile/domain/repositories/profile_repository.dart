import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/follow_list_type.dart';
import '../entities/profile_changes.dart';
import '../entities/profile_photo.dart';
import '../entities/user_profile.dart';
import '../entities/user_summary.dart';

/// Contrato del módulo de perfil: ver, editar, buscar personas y las
/// listas de seguidores, seguidos y visitas.
abstract interface class ProfileRepository {
  /// Perfil de [userId]. Si es el propio, incluye los datos privados.
  /// Si no existe (cuenta borrada), devuelve [DataFailure.notFound].
  Future<Result<UserProfile, DataFailure>> getProfile(String userId);

  /// Guarda cambios del perfil propio. Si el nombre de usuario ya está
  /// ocupado, devuelve [DataFailure.conflict].
  Future<Result<void, DataFailure>> updateProfile(ProfileChanges changes);

  /// Sube la foto y la guarda en el perfil. Devuelve la URL pública.
  Future<Result<String, DataFailure>> uploadAvatar({
    required String userId,
    required ProfilePhoto photo,
  });

  Future<Result<bool, DataFailure>> isUsernameAvailable(String username);

  /// Busca por nombre o usuario (sin incluirme).
  Future<Result<List<UserSummary>, DataFailure>> searchUsers(String query);

  Future<Result<List<UserSummary>, DataFailure>> getFollowList(
    String userId,
    FollowListType type,
  );

  /// Avisa que visité el perfil de [profileId].
  Future<Result<void, DataFailure>> registerProfileView(String profileId);

  /// Quién visitó mi perfil en los últimos 30 días.
  Future<Result<List<UserSummary>, DataFailure>> getProfileViewers();
}
