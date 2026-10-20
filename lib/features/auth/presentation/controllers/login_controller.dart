import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../di/auth_providers.dart';

/// Estado de la pantalla de inicio de sesión: en reposo, cargando
/// (`AsyncLoading`) o con error (`AsyncError` con un `AuthFailure`).
///
/// No navega: cuando la sesión cambia, el router lleva al usuario al inicio.
final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, void>(
      LoginController.new,
    );

class LoginController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit({required String email, required String password}) async {
    state = const AsyncLoading<void>();
    final result = await ref
        .read(signInProvider)
        .call(email: email, password: password);
    if (!ref.mounted) return;

    state = switch (result) {
      Ok() => const AsyncData<void>(null),
      Err(:final error) => AsyncError<void>(error, StackTrace.current),
    };
  }
}
