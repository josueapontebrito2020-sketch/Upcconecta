import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Casilla obligatoria de autorización de datos personales (Ley 1581 de
/// 2012). Es un campo del formulario: si no está marcada, el formulario no
/// se envía y muestra el error debajo.
class DataConsentField extends StatelessWidget {
  const DataConsentField({super.key, this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return FormField<bool>(
      initialValue: false,
      validator: (accepted) =>
          accepted == true ? null : l10n.validationConsentRequired,
      builder: (field) {
        final errorText = field.errorText;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              value: field.value ?? false,
              onChanged: enabled ? field.didChange : null,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              title: Text(
                l10n.dataConsent,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.tinta),
              ),
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  errorText,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ),
          ],
        );
      },
    );
  }
}
