import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/domain/entities/profile_photo.dart';

/// Registro que espera el código del correo: guarda el correo (para
/// verificar y reenviar el código) y la foto elegida (que se sube cuando
/// la cuenta ya está verificada).
class PendingSignUp {
  const PendingSignUp({required this.email, this.photo});

  final String email;
  final ProfilePhoto? photo;
}

final pendingSignUpProvider =
    NotifierProvider<PendingSignUpNotifier, PendingSignUp?>(
      PendingSignUpNotifier.new,
    );

class PendingSignUpNotifier extends Notifier<PendingSignUp?> {
  @override
  PendingSignUp? build() => null;

  void save(PendingSignUp pending) => state = pending;

  void clear() => state = null;
}
