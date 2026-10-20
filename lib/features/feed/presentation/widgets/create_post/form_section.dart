import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Bloque blanco con título del formulario "Publicar".
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.errorText,
  });

  final String title;
  final String? subtitle;

  /// Mensaje en rojo debajo del contenido (ej. "Elige una categoría").
  final String? errorText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitleText = subtitle;
    final error = errorText;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.verdeProfundo.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitleText != null) ...[
              const SizedBox(height: 2),
              Text(subtitleText, style: textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            child,
            if (error != null) ...[
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(
                  error,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
