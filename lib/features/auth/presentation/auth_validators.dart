import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/institutional_email.dart';

/// Validaciones de los formularios de autenticación. Cada método devuelve el
/// mensaje de error, o `null` si el valor es válido.
///
/// Uso en una pantalla: `final validators = AuthValidators(context.l10n);`
class AuthValidators {
  const AuthValidators(this._l10n);

  final AppLocalizations _l10n;

  static final RegExp _username = RegExp(
    '^[a-z0-9_.]{${AppConstants.usernameMinLength},${AppConstants.usernameMaxLength}}\$',
  );
  static final RegExp _colombianMobile = RegExp(r'^3\d{9}$');
  static final RegExp _digits = RegExp(r'^\d+$');

  String? institutionalEmail(String? value) {
    final email = normalizeEmail(value ?? '');
    if (email.isEmpty) return _l10n.validationEmailRequired;
    if (!email.contains('@')) {
      return _l10n.validationEmailIncomplete(AppConstants.institutionalDomain);
    }
    if (!isInstitutionalEmail(email)) {
      return _l10n.validationEmailNotInstitutional(
        AppConstants.institutionalDomain,
      );
    }
    return null;
  }

  /// Al iniciar sesión solo se revisa que no esté vacía.
  String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return _l10n.validationPasswordRequired;
    return null;
  }

  String? fullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return _l10n.validationFullNameRequired;
    if (!name.contains(' ')) return _l10n.validationFullNameIncomplete;
    return null;
  }

  String? username(String? value) {
    final username = value?.trim().toLowerCase() ?? '';
    if (username.isEmpty) return _l10n.validationUsernameRequired;
    if (!_username.hasMatch(username)) {
      return _l10n.validationUsernameFormat(
        AppConstants.usernameMinLength,
        AppConstants.usernameMaxLength,
      );
    }
    return null;
  }

  String? birthDate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return _l10n.validationBirthDateRequired;
    final date = parseDayMonthYear(text);
    if (date == null) return _l10n.validationBirthDateInvalid;
    final age = ageOn(date, DateTime.now());
    if (age < AppConstants.minAge || age > AppConstants.maxAge) {
      return _l10n.validationBirthDateAge(
        AppConstants.minAge,
        AppConstants.maxAge,
      );
    }
    return null;
  }

  String? faculty(int? value) {
    return value == null ? _l10n.validationFacultyRequired : null;
  }

  String? program(int? value) {
    return value == null ? _l10n.validationProgramRequired : null;
  }

  /// El celular es opcional: vacío es válido.
  String? optionalPhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;
    if (!_colombianMobile.hasMatch(phone)) return _l10n.validationPhoneFormat;
    return null;
  }

  String? newPassword(String? value) {
    final password = value ?? '';
    if (password.length < AppConstants.minPasswordLength) {
      return _l10n.validationPasswordLength(AppConstants.minPasswordLength);
    }
    final hasLetter = RegExp(r'[A-Za-zÁÉÍÓÚÑáéíóúñ]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    if (!hasLetter || !hasNumber) return _l10n.validationPasswordLettersNumbers;
    return null;
  }

  /// Compara con la contraseña escrita en el otro campo.
  String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if (value == null || value.isEmpty) {
        return _l10n.validationPasswordConfirmRequired;
      }
      if (value != original()) return _l10n.validationPasswordMismatch;
      return null;
    };
  }

  String? verificationCode(String? value) {
    final code = value?.trim() ?? '';
    final validLength =
        code.length >= AppConstants.otpMinLength &&
        code.length <= AppConstants.otpMaxLength;
    if (!validLength || !_digits.hasMatch(code)) {
      return _l10n.validationCodeFormat;
    }
    return null;
  }
}
