import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/profile_photo.dart';
import '../repositories/profile_repository.dart';

/// Sube la foto de perfil del usuario.
class UploadAvatar {
  const UploadAvatar(this._repository);

  final ProfileRepository _repository;

  Future<Result<String, DataFailure>> call({
    required String userId,
    required ProfilePhoto photo,
  }) {
    return _repository.uploadAvatar(userId: userId, photo: photo);
  }
}
