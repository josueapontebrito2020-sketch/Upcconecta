import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Tarjeta blanca centrada con sombra (efecto 3D) donde va cada formulario
/// de acceso: logo, título, descripción y el contenido.
///
/// Se muestra sobre el fondo verde de `AuthShell`. Si el contenido es más
/// alto que la pantalla, la tarjeta se desplaza.
class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.onBack,
    this.logo,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  /// Si no es null, muestra la flecha para volver.
  final VoidCallback? onBack;

  /// Logo personalizado (el login lo anima). Si es null, se usa el normal.
  final Widget? logo;

  /// Sombra en dos capas: una amplia y difusa que "levanta" la tarjeta y
  /// otra corta y cercana que le da borde.
  static final List<BoxShadow> shadow = [
    BoxShadow(
      color: AppColors.verdeProfundo.withValues(alpha: 0.45),
      blurRadius: 48,
      spreadRadius: -6,
      offset: const Offset(0, 28),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final subtitleText = subtitle;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.superficie,
                borderRadius: BorderRadius.circular(28),
                boxShadow: shadow,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 40,
                      child: onBack == null
                          ? null
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: onBack,
                                tooltip: l10n.backTooltip,
                                color: AppColors.verdeUpc,
                                icon: const Icon(Icons.arrow_back),
                              ),
                            ),
                    ),
                    Center(
                      child:
                          logo ??
                          Image.asset(
                            AppAssets.logo,
                            height: 96,
                            semanticLabel: l10n.logoLabel,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall,
                    ),
                    if (subtitleText != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitleText,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 24),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
