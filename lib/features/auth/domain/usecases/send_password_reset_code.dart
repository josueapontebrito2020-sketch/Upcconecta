import '../../../../core/errors/result.dart';
import '../entities/auth_failure.dart';
import '../institutional_email.dart';
import '../repositories/auth_repository.dart';

/// Envía al correo institucional el código para crear una contraseña nueva.
class SendPasswordResetCode {
  const SendPasswordResetCode(this._repository);

  final AuthRepository _repository;

  Future<Result<void, AuthFailure>> call(String email) async {
    final normalized = normalizeEmail(email);
    if (!isInstitutionalEmail(normalized)) {
      return const Err<void, AuthFailure>(AuthFailure.nonInstitutionalEmail);
    }
    return _repository.sendPasswordResetCode(normalized);
  }
}
