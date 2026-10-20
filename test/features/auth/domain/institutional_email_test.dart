import 'package:flutter_test/flutter_test.dart';
import 'package:upcconect/features/auth/domain/institutional_email.dart';

void main() {
  group('isInstitutionalEmail', () {
    test('acepta correos @unicesar.edu.co', () {
      expect(isInstitutionalEmail('ana.perez@unicesar.edu.co'), isTrue);
      expect(isInstitutionalEmail('jperez23@unicesar.edu.co'), isTrue);
    });

    test('ignora mayúsculas y espacios', () {
      expect(isInstitutionalEmail('  Ana@UNICESAR.edu.co '), isTrue);
    });

    test('rechaza otros dominios', () {
      expect(isInstitutionalEmail('ana@gmail.com'), isFalse);
      expect(isInstitutionalEmail('ana@unicesar.edu.co.com'), isFalse);
      expect(isInstitutionalEmail('ana@falso-unicesar.edu.co'), isFalse);
      expect(isInstitutionalEmail('ana@unicesarxedu.co'), isFalse);
    });

    test('rechaza correos incompletos', () {
      expect(isInstitutionalEmail(''), isFalse);
      expect(isInstitutionalEmail('@unicesar.edu.co'), isFalse);
      expect(isInstitutionalEmail('ana'), isFalse);
    });
  });
}
