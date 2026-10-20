import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../profile/domain/entities/profile_photo.dart';
import '../../di/auth_providers.dart';
import '../../domain/entities/sign_up_data.dart';
import '../../domain/institutional_email.dart';
import '../providers/pending_sign_up_provider.dart';
import 'auth_async_state.dart';

/// Estado de la pantalla "Crea tu cuenta".
final registerControllerProvider =
    AsyncNotifierProvider.autoDispose<RegisterController, void>(
      RegisterController.new,
    );

class RegisterController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Crea la cuenta. Devuelve true si se envió el código al correo; en ese
  /// caso la pantalla lleva al usuario a verificarlo.
  Future<bool> submit({required SignUpData data, ProfilePhoto? photo}) async {
    state = const AsyncLoading<void>();

    final signUp = ref.read(signUpProvider);
    final pendingSignUp = ref.read(pendingSignUpProvider.notifier);

    final result = await signUp(data);
    final succeeded = result is Ok;
    if (succeeded) {
      pendingSignUp.save(
        PendingSignUp(email: normalizeEmail(data.email), photo: photo),
      );
    }

    if (ref.mounted) state = authAsyncStateFrom(result);
    return succeeded;
  }
}
