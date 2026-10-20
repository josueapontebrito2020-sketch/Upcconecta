import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../di/auth_providers.dart';
import '../../domain/institutional_email.dart';
import '../providers/password_reset_email_provider.dart';
import 'auth_async_state.dart';

/// Estado de la pantalla "Recupera tu contraseña".
final forgotPasswordControllerProvider =
    AsyncNotifierProvider.autoDispose<ForgotPasswordController, void>(
      ForgotPasswordController.new,
    );

class ForgotPasswordController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Devuelve true si se envió el código; la pantalla pasa entonces a
  /// "Crea una contraseña nueva".
  Future<bool> sendCode(String email) async {
    state = const AsyncLoading<void>();

    final sendResetCode = ref.read(sendPasswordResetCodeProvider);
    final resetEmail = ref.read(passwordResetEmailProvider.notifier);

    final result = await sendResetCode(email);
    final succeeded = result is Ok;
    if (succeeded) resetEmail.save(normalizeEmail(email));

    if (ref.mounted) state = authAsyncStateFrom(result);
    return succeeded;
  }
}
