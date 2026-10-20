import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/sign_up_data.dart';
import '../../domain/repositories/auth_repository.dart';

/// Autenticación con Supabase Auth (correo, contraseña y código al correo).
///
/// Es la única clase del módulo que conoce Supabase: convierte sus usuarios
/// a [AppUser] y sus errores a [AuthFailure].
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.onAuthStateChange.map(
      (state) => _toAppUser(state.session?.user),
    );
  }

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Future<Result<AppUser, AuthFailure>> signIn({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return _requireUser(response.user);
    });
  }

  @override
  Future<Result<void, AuthFailure>> signUp(SignUpData data) {
    return _guard(() async {
      final response = await _auth.signUp(
        email: data.email,
        password: data.password,
        // Estos datos los lee el trigger handle_new_user para crear el perfil.
        data: {
          'full_name': data.fullName.trim(),
          'username': data.username,
          'birth_date': formatIsoDate(data.birthDate),
          'phone': data.phone,
          'faculty_id': data.facultyId,
          'program_id': data.programId,
          'bio': data.bio.trim(),
        },
      );

      // Si el correo ya tenía una cuenta confirmada, Supabase no da error
      // (para no revelar qué correos existen) pero devuelve un usuario sin
      // identidades.
      final identities = response.user?.identities;
      if (identities != null && identities.isEmpty) {
        return const Err(AuthFailure.emailAlreadyInUse);
      }
      return const Ok(null);
    });
  }

  @override
  Future<Result<AppUser, AuthFailure>> verifySignUpCode({
    required String email,
    required String code,
  }) {
    return _guard(() async {
      final response = await _auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: code,
      );
      return _requireUser(response.user);
    });
  }

  @override
  Future<Result<void, AuthFailure>> resendSignUpCode(String email) {
    return _guard(() async {
      await _auth.resend(type: OtpType.signup, email: email);
      return const Ok(null);
    });
  }

  @override
  Future<Result<bool, AuthFailure>> isUsernameAvailable(String username) {
    return _guard(() async {
      final available = await _client.rpc(
        'is_username_available',
        params: {'p_username': username},
      );
      return Ok(available == true);
    });
  }

  @override
  Future<Result<void, AuthFailure>> sendPasswordResetCode(String email) {
    return _guard(() async {
      // Usa la plantilla "Reset Password", que debe incluir {{ .Token }}.
      await _auth.resetPasswordForEmail(email);
      return const Ok(null);
    });
  }

  @override
  Future<Result<AppUser, AuthFailure>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _guard(() async {
      // 1. El código correcto inicia una sesión de recuperación.
      await _auth.verifyOTP(type: OtpType.recovery, email: email, token: code);
      // 2. Con esa sesión se guarda la contraseña nueva.
      final response = await _auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return _requireUser(response.user);
    });
  }

  @override
  Future<void> signOut() => _auth.signOut();

  /// Ejecuta una llamada a Supabase y convierte cualquier error en
  /// [AuthFailure], para que nunca llegue una excepción a la interfaz.
  Future<Result<T, AuthFailure>> _guard<T>(
    Future<Result<T, AuthFailure>> Function() call,
  ) async {
    try {
      return await call();
    } on AuthException catch (error) {
      developer.log('Error de Supabase Auth: ${error.code}', error: error);
      return Err(_toFailure(error));
    } on PostgrestException catch (error) {
      developer.log('Error de base de datos', error: error);
      return const Err(AuthFailure.unknown);
    } catch (error) {
      developer.log('Error inesperado', error: error);
      return const Err(AuthFailure.network);
    }
  }

  static Result<AppUser, AuthFailure> _requireUser(User? user) {
    final appUser = _toAppUser(user);
    if (appUser == null) return const Err(AuthFailure.unknown);
    return Ok(appUser);
  }

  static AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    final fullName = user.userMetadata?['full_name'];
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: fullName is String ? fullName : '',
      emailVerified: user.emailConfirmedAt != null,
    );
  }

  /// Códigos de error de Supabase Auth:
  /// https://supabase.com/docs/guides/auth/debugging/error-codes
  static AuthFailure _toFailure(AuthException error) {
    if (error is AuthRetryableFetchException) {
      // Sin código HTTP: no hubo respuesta (sin internet).
      // Con código (500, 504…): el servidor respondió, pero falló algo allá.
      return error.statusCode == null ? AuthFailure.network : AuthFailure.unknown;
    }
    // Supabase no pudo enviar el correo con el código (SMTP mal configurado,
    // límite de envíos, etc.).
    final message = error.message.toLowerCase();
    if (message.contains('sending') && message.contains('email')) {
      return AuthFailure.emailDeliveryFailed;
    }
    return switch (error.code) {
      'invalid_credentials' => AuthFailure.invalidCredentials,
      'email_not_confirmed' => AuthFailure.emailNotVerified,
      'user_already_exists' || 'email_exists' => AuthFailure.emailAlreadyInUse,
      'weak_password' => AuthFailure.weakPassword,
      'same_password' => AuthFailure.samePassword,
      'otp_expired' => AuthFailure.invalidCode,
      'email_address_not_authorized' => AuthFailure.emailDeliveryFailed,
      'over_request_rate_limit' ||
      'over_email_send_rate_limit' => AuthFailure.tooManyRequests,
      _ => AuthFailure.unknown,
    };
  }
}
