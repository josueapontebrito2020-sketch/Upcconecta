import '../../../../core/errors/result.dart';
import '../entities/app_user.dart';
import '../entities/auth_failure.dart';
import '../entities/sign_up_data.dart';

/// Contrato de autenticación. Las pantallas y los casos de uso solo conocen
/// esta interfaz; la implementación (Supabase o la de prueba) vive en `data/`
/// y se elige en `di/auth_providers.dart`.
abstract interface class AuthRepository {
  /// Emite el usuario cada vez que cambia la sesión (o `null` al cerrarla).
  Stream<AppUser?> authStateChanges();

  /// Usuario con sesión iniciada en este momento, o `null`.
  AppUser? get currentUser;

  Future<Result<AppUser, AuthFailure>> signIn({
    required String email,
    required String password,
  });

  /// Crea la cuenta y envía al correo el código de verificación.
  /// No inicia sesión: eso pasa al verificar el código.
  Future<Result<void, AuthFailure>> signUp(SignUpData data);

  /// Comprueba el código del correo. Si es correcto, inicia sesión.
  Future<Result<AppUser, AuthFailure>> verifySignUpCode({
    required String email,
    required String code,
  });

  Future<Result<void, AuthFailure>> resendSignUpCode(String email);

  Future<Result<bool, AuthFailure>> isUsernameAvailable(String username);

  /// Envía al correo un código para crear una contraseña nueva. Responde
  /// igual exista o no la cuenta, para no revelar qué correos están
  /// registrados.
  Future<Result<void, AuthFailure>> sendPasswordResetCode(String email);

  /// Comprueba el código y cambia la contraseña. Si todo sale bien, el
  /// usuario queda con la sesión iniciada.
  Future<Result<AppUser, AuthFailure>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> signOut();
}
