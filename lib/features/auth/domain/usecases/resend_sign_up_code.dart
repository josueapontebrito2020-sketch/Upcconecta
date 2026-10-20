import '../../../../core/errors/result.dart';
import '../entities/auth_failure.dart';
import '../repositories/auth_repository.dart';

/// Envía otra vez el código de verificación al correo.
class ResendSignUpCode {
  const ResendSignUpCode(this._repository);

  final AuthRepository _repository;

  Future<Result<void, AuthFailure>> call(String email) {
    return _repository.resendSignUpCode(email);
  }
}
