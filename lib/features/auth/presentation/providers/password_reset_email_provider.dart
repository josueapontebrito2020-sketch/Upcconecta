import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Correo al que se envió el código para recuperar la contraseña. Lo usa la
/// pantalla "Crea una contraseña nueva" para verificar y reenviar el código.
final passwordResetEmailProvider =
    NotifierProvider<PasswordResetEmailNotifier, String?>(
      PasswordResetEmailNotifier.new,
    );

class PasswordResetEmailNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void save(String email) => state = email;
}
