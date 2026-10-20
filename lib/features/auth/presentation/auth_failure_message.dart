import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/auth_failure.dart';

/// Texto que ve el usuario para cada error: qué pasó y qué puede hacer.
extension AuthFailureMessage on AuthFailure {
  String message(AppLocalizations l10n) => switch (this) {
    AuthFailure.invalidCredentials => l10n.errorInvalidCredentials,
    AuthFailure.emailAlreadyInUse => l10n.errorEmailAlreadyInUse,
    AuthFailure.usernameTaken => l10n.errorUsernameTaken,
    AuthFailure.nonInstitutionalEmail => l10n.errorNonInstitutionalEmail(
      AppConstants.institutionalDomain,
    ),
    AuthFailure.weakPassword => l10n.errorWeakPassword(
      AppConstants.minPasswordLength,
    ),
    AuthFailure.samePassword => l10n.errorSamePassword,
    AuthFailure.emailNotVerified => l10n.errorEmailNotVerified,
    AuthFailure.invalidCode => l10n.errorInvalidCode,
    AuthFailure.emailDeliveryFailed => l10n.errorEmailDelivery,
    AuthFailure.tooManyRequests => l10n.errorTooManyRequests,
    AuthFailure.network => l10n.errorNetwork,
    AuthFailure.unknown => l10n.errorUnknown,
  };
}

/// Extrae el [AuthFailure] del estado de un controlador, si lo hay.
extension AuthFailureState on AsyncValue<void> {
  AuthFailure? get authFailure => switch (this) {
    AsyncError(error: final AuthFailure failure) => failure,
    _ => null,
  };
}
