import 'package:flutter/services.dart';

/// Pone las barras de la fecha mientras se escribe:
/// "24" → "24", "2403" → "24/03", "24032005" → "24/03/2005".
///
/// Se usa después de `FilteringTextInputFormatter.digitsOnly`, así que
/// siempre recibe solo números.
class DateTextInputFormatter extends TextInputFormatter {
  const DateTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.length > 8
        ? newValue.text.substring(0, 8)
        : newValue.text;

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
