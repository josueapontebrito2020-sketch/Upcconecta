import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import '../core/extensions/context_extensions.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/primary_button.dart';
import '../l10n/app_localizations.dart';

/// Pantalla que se muestra si la app no pudo iniciar (por ejemplo, sin
/// internet o si falla un componente del teléfono). Así nunca queda la
/// pantalla en negro: se explica qué pasó y se puede reintentar.
class StartupErrorApp extends StatefulWidget {
  const StartupErrorApp({super.key, required this.onRetry});

  /// Vuelve a intentar iniciar la app.
  final Future<void> Function() onRetry;

  @override
  State<StartupErrorApp> createState() => _StartupErrorAppState();
}

class _StartupErrorAppState extends State<StartupErrorApp> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    await widget.onRetry();
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('es'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) {
          final l10n = context.l10n;
          final textTheme = Theme.of(context).textTheme;
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          AppAssets.logo,
                          height: 110,
                          semanticLabel: l10n.logoLabel,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.startupErrorTitle,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.startupErrorMessage,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: l10n.retryButton,
                          isLoading: _retrying,
                          onPressed: _retry,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
