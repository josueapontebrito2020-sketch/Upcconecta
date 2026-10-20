import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../repositories/profile_repository.dart';

/// Cuenta una visita al perfil de otra persona.
class RegisterProfileView {
  const RegisterProfileView(this._repository);

  final ProfileRepository _repository;

  Future<Result<void, DataFailure>> call(String profileId) {
    return _repository.registerProfileView(profileId);
  }
}
