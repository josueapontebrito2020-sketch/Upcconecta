import '../../../../core/errors/result.dart';
import '../entities/app_user.dart';
import '../entities/auth_failure.dart';
import '../repositories/auth_repository.dart';

/// Comprueba el código del correo y guarda la contraseña nueva.
class ResetPassword {
  const ResetPassword(this._repository);

  final AuthRepository _repository;

  Future<Result<AppUser, AuthFailure>> call({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _repository.resetPassword(
      email: email,
      code: code.trim(),
      newPassword: newPassword,
    );
  }
}
