import '../../../../core/errors/result.dart';
import '../entities/auth_failure.dart';
import '../entities/sign_up_data.dart';
import '../institutional_email.dart';
import '../repositories/auth_repository.dart';

/// Crea la cuenta: revisa que el correo sea institucional y que el nombre
/// de usuario esté libre; luego Supabase envía el código al correo.
class SignUp {
  const SignUp(this._repository);

  final AuthRepository _repository;

  Future<Result<void, AuthFailure>> call(SignUpData data) async {
    final email = normalizeEmail(data.email);
    if (!isInstitutionalEmail(email)) {
      return const Err<void, AuthFailure>(AuthFailure.nonInstitutionalEmail);
    }

    final username = data.username.trim().toLowerCase();
    final availability = await _repository.isUsernameAvailable(username);
    switch (availability) {
      case Err(:final error):
        return Err<void, AuthFailure>(error);
      case Ok(value: false):
        return const Err<void, AuthFailure>(AuthFailure.usernameTaken);
      case Ok(value: true):
        break;
    }

    return _repository.signUp(data.copyWith(email: email, username: username));
  }
}
