import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/profile_changes.dart';
import '../repositories/profile_repository.dart';

/// Guarda cambios del perfil propio, ya limpios: sin espacios de sobra y el
/// nombre de usuario en minúsculas.
class UpdateProfile {
  const UpdateProfile(this._repository);

  final ProfileRepository _repository;

  Future<Result<void, DataFailure>> call(ProfileChanges changes) async {
    final phone = changes.phone?.replaceAll(RegExp(r'\s'), '');
    final clean = ProfileChanges(
      fullName: changes.fullName?.trim(),
      username: changes.username?.trim().toLowerCase(),
      bio: changes.bio?.trim(),
      phone: phone == null || phone.isEmpty ? null : phone,
      clearPhone: changes.clearPhone || (phone != null && phone.isEmpty),
      facultyId: changes.facultyId,
      programId: changes.programId,
      birthDate: changes.birthDate,
    );
    if (clean.isEmpty) return const Ok(null);
    return _repository.updateProfile(clean);
  }
}
