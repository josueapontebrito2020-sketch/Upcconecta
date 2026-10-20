import '../../../../core/errors/result.dart';
import '../entities/app_user.dart';
import '../entities/auth_failure.dart';
import '../institutional_email.dart';
import '../repositories/auth_repository.dart';

/// Inicia sesión solo con correos institucionales.
class SignIn {
  const SignIn(this._repository);

  final AuthRepository _repository;

  Future<Result<AppUser, AuthFailure>> call({
    required String email,
    required String password,
  }) async {
    final normalized = normalizeEmail(email);
    if (!isInstitutionalEmail(normalized)) {
      return const Err<AppUser, AuthFailure>(AuthFailure.nonInstitutionalEmail);
    }
    return _repository.signIn(email: normalized, password: password);
  }
}
