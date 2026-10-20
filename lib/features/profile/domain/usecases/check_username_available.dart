import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../repositories/profile_repository.dart';

/// ¿El nombre de usuario está libre?
class CheckUsernameAvailable {
  const CheckUsernameAvailable(this._repository);

  final ProfileRepository _repository;

  Future<Result<bool, DataFailure>> call(String username) {
    return _repository.isUsernameAvailable(username.trim().toLowerCase());
  }
}
