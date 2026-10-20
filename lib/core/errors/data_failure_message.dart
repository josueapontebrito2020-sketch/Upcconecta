import '../../l10n/app_localizations.dart';
import 'data_failure.dart';

/// Texto que ve el usuario para cada [DataFailure].
extension DataFailureMessage on DataFailure {
  String message(AppLocalizations l10n) {
    return switch (this) {
      DataFailure.network => l10n.errorNetwork,
      DataFailure.notFound => l10n.errorNotFound,
      DataFailure.conflict => l10n.errorConflict,
      DataFailure.unknown => l10n.errorUnknown,
    };
  }
}
