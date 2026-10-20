import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../profile/di/profile_providers.dart';
import '../../di/auth_providers.dart';
import '../../domain/entities/auth_failure.dart';
import '../providers/pending_sign_up_provider.dart';
import 'auth_async_state.dart';

/// Estado de la pantalla "Verifica tu correo".
///
/// Al verificar el código se inicia la sesión y el router lleva al usuario
/// al inicio; antes de eso se sube la foto de perfil, si eligió una.
final verifyEmailControllerProvider =
    AsyncNotifierProvider.autoDispose<VerifyEmailController, void>(
      VerifyEmailController.new,
    );

class VerifyEmailController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> verify(String code) async {
    final pending = ref.read(pendingSignUpProvider);
    if (pending == null) {
      state = AsyncError<void>(AuthFailure.unknown, StackTrace.current);
      return;
    }
    state = const AsyncLoading<void>();

    // Se leen antes de esperar: si la pantalla se cierra mientras tanto,
    // el trabajo termina igual.
    final verifyCode = ref.read(verifySignUpCodeProvider);
    final uploadAvatar = ref.read(uploadAvatarProvider);

    final result = await verifyCode(email: pending.email, code: code);
    final photo = pending.photo;
    if (result case Ok(value: final user) when photo != null) {
      // Si la foto falla, la cuenta igual queda creada; se puede subir
      // después desde el perfil.
      await uploadAvatar(userId: user.id, photo: photo);
    }

    if (ref.mounted) state = authAsyncStateFrom(result);
  }

  /// Devuelve true si se envió un código nuevo.
  Future<bool> resend() async {
    final pending = ref.read(pendingSignUpProvider);
    if (pending == null) return false;
    state = const AsyncLoading<void>();

    final result = await ref.read(resendSignUpCodeProvider).call(pending.email);

    if (ref.mounted) state = authAsyncStateFrom(result);
    return result is Ok;
  }
}
