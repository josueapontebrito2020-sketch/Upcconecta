import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env.dart';
import '../../../core/di/supabase_providers.dart';
import '../data/repositories/fake_auth_repository.dart';
import '../data/repositories/supabase_auth_repository.dart';
import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/resend_sign_up_code.dart';
import '../domain/usecases/reset_password.dart';
import '../domain/usecases/send_password_reset_code.dart';
import '../domain/usecases/sign_in.dart';
import '../domain/usecases/sign_out.dart';
import '../domain/usecases/sign_up.dart';
import '../domain/usecases/verify_sign_up_code.dart';

// Inyección de dependencias del módulo de autenticación (composition root).
// Es el único archivo que conoce las tres capas y las conecta: las pantallas
// piden casos de uso, sin saber si detrás está Supabase o la versión de prueba.

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppEnv.hasSupabase) {
    return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
  }
  final fake = FakeAuthRepository();
  ref.onDispose(fake.dispose);
  return fake;
});

/// Avisa cada vez que se inicia o se cierra sesión.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Usuario con sesión en este momento (null si no hay). Se recalcula al
/// iniciar o cerrar sesión, así ninguna pantalla se queda con la cuenta
/// anterior.
final currentUserProvider = Provider<AppUser?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(authRepositoryProvider).currentUser;
});

final signInProvider = Provider<SignIn>((ref) {
  return SignIn(ref.watch(authRepositoryProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});

final signUpProvider = Provider<SignUp>((ref) {
  return SignUp(ref.watch(authRepositoryProvider));
});

final verifySignUpCodeProvider = Provider<VerifySignUpCode>((ref) {
  return VerifySignUpCode(ref.watch(authRepositoryProvider));
});

final resendSignUpCodeProvider = Provider<ResendSignUpCode>((ref) {
  return ResendSignUpCode(ref.watch(authRepositoryProvider));
});

final sendPasswordResetCodeProvider = Provider<SendPasswordResetCode>((ref) {
  return SendPasswordResetCode(ref.watch(authRepositoryProvider));
});

final resetPasswordProvider = Provider<ResetPassword>((ref) {
  return ResetPassword(ref.watch(authRepositoryProvider));
});
