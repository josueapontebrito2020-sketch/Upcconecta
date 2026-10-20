import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

extension ContextExtensions on BuildContext {
  /// Textos de la app: `context.l10n.signInButton`.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Muestra un aviso corto abajo, reemplazando el anterior si lo había.
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
