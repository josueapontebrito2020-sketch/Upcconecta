import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcconect/core/utils/date_text_input_formatter.dart';
import 'package:upcconect/core/utils/date_utils.dart';

void main() {
  group('parseDayMonthYear', () {
    test('lee una fecha válida', () {
      expect(parseDayMonthYear('24/03/2005'), DateTime(2005, 3, 24));
    });

    test('rechaza fechas que no existen o incompletas', () {
      expect(parseDayMonthYear('31/02/2005'), isNull);
      expect(parseDayMonthYear('24/03/05'), isNull);
      expect(parseDayMonthYear('24/03'), isNull);
    });
  });

  test('ageOn cuenta si ya cumplió años', () {
    final birth = DateTime(2005, 3, 24);
    expect(ageOn(birth, DateTime(2026, 3, 23)), 20);
    expect(ageOn(birth, DateTime(2026, 3, 24)), 21);
  });

  test('DateTextInputFormatter pone las barras', () {
    const formatter = DateTextInputFormatter();
    String format(String digits) => formatter
        .formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: digits),
        )
        .text;

    expect(format('24'), '24');
    expect(format('2403'), '24/03');
    expect(format('24032005'), '24/03/2005');
    expect(format('240320059'), '24/03/2005');
  });
}
