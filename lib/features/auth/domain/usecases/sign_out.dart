import '../repositories/auth_repository.dart';

/// Cierra la sesión del usuario actual.
class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
