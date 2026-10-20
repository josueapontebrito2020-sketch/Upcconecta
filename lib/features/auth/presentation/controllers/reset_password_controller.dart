import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../di/auth_providers.dart';
import '../../domain/entities/auth_failure.dart';
import '../providers/password_reset_email_provider.dart';
import 'auth_async_state.dart';

/// Estado de la pantalla "Crea una contraseña nueva".
///
/// Si el código es correcto, la contraseña cambia, se inicia la sesión y el
/// router lleva al usuario al inicio.
final resetPasswordControllerProvider =
    AsyncNotifierProvider.autoDispose<ResetPasswordController, void>(
      ResetPasswordController.new,
    );

class ResetPasswordController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> reset({required String code, required String newPassword}) async {
    final email = ref.read(passwordResetEmailProvider);
    if (email == null) {
      state = AsyncError<void>(AuthFailure.unknown, StackTrace.current);
      return;
    }
    state = const AsyncLoading<void>();

    final result = await ref
        .read(resetPasswordProvider)
        .call(email: email, code: code, newPassword: newPassword);

    if (ref.mounted) state = authAsyncStateFrom(result);
  }

  /// Devuelve true si se envió un código nuevo.
  Future<bool> resend() async {
    final email = ref.read(passwordResetEmailProvider);
    if (email == null) return false;
    state = const AsyncLoading<void>();

    final result = await ref.read(sendPasswordResetCodeProvider).call(email);

    if (ref.mounted) state = authAsyncStateFrom(result);
    return result is Ok;
  }
}
