import 'package:flutter/services.dart';

/// Convierte a minúsculas mientras se escribe (para el nombre de usuario).
class LowerCaseTextFormatter extends TextInputFormatter {
  const LowerCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}
