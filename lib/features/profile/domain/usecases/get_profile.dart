import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Perfil de una persona (con sus contadores).
class GetProfile {
  const GetProfile(this._repository);

  final ProfileRepository _repository;

  Future<Result<UserProfile, DataFailure>> call(String userId) {
    return _repository.getProfile(userId);
  }
}
