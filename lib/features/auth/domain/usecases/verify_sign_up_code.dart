import '../../../../core/errors/result.dart';
import '../entities/app_user.dart';
import '../entities/auth_failure.dart';
import '../repositories/auth_repository.dart';

/// Comprueba el código que llegó al correo y, si es correcto, inicia sesión.
class VerifySignUpCode {
  const VerifySignUpCode(this._repository);

  final AuthRepository _repository;

  Future<Result<AppUser, AuthFailure>> call({
    required String email,
    required String code,
  }) {
    return _repository.verifySignUpCode(email: email, code: code.trim());
  }
}
