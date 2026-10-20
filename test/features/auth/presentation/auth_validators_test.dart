import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcconect/features/auth/presentation/auth_validators.dart';
import 'package:upcconect/l10n/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('es'));
  final validators = AuthValidators(l10n);

  group('AuthValidators.institutionalEmail', () {
    test('pide el correo si está vacío', () {
      expect(
        validators.institutionalEmail('  '),
        l10n.validationEmailRequired,
      );
    });

    test('rechaza otros dominios', () {
      expect(validators.institutionalEmail('ana@gmail.com'), isNotNull);
    });

    test('acepta el correo institucional', () {
      expect(validators.institutionalEmail('ana@unicesar.edu.co'), isNull);
    });
  });

  group('AuthValidators.loginPassword', () {
    test('pide la contraseña si está vacía', () {
      expect(validators.loginPassword(''), isNotNull);
      expect(validators.loginPassword('Clave1234'), isNull);
    });
  });
}
